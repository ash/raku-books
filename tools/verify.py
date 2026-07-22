#!/usr/bin/env python3
"""
verify.py — decide whether a Raku code block deserves a Run button, by compiling
and running it under two compilers at build time.

Two reasons a block should NOT be runnable, distinguished here:

  * FRAGMENT   — not a complete program (a partial listing, or a snippet that
                 reuses a variable from an earlier block). Signal: it fails to
                 compile under Rakudo (`raku -c`), the reference compiler.
  * RAKUPP GAP — a valid, complete program that the in-browser engine (Raku++)
                 cannot run correctly yet. Signal: Rakudo compiles AND runs it,
                 but Raku++ errors or prints something different.

A block is runnable only when Rakudo runs it cleanly and Raku++ reproduces the
same output (or the program is non-deterministic and Raku++ at least runs cleanly).

Verdicts are cached by code hash in tools/verdict-cache.json so re-extraction is
fast. Runs are sandboxed to a temp cwd with empty stdin and a timeout.

Env:  RAKUDO (default "raku"), RAKUPP (default the arm64 build), VERIFY_TIMEOUT.
"""
import hashlib, json, os, re, subprocess, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE_PATH = os.path.join(HERE, "verdict-cache.json")
# Bump when the verdict logic changes, so stale cached verdicts are discarded.
CACHE_VERSION = 3

RAKUDO = os.environ.get("RAKUDO", "raku")
RAKUPP = os.environ.get("RAKUPP", "/Users/ash/raku++/build-arm64/rakupp")
TIMEOUT = int(os.environ.get("VERIFY_TIMEOUT", "12"))

# Strong error signatures — matched in a compiler's combined output to tell a
# genuine failure from a benign warning. (Rakudo warnings go to stderr but we
# compare stdout for correctness, so they don't matter there.)
ERR_RE = re.compile(
    r"===SORRY===|Unhandled exception|not declared|Undeclared|No such method|"
    r"Cannot resolve|Could not|Malformed|Unexpected|Died|X::|Ambiguous|"
    r"does not|doesn't|Type check|coerce|Method .* not found",
    re.I)

# A program that touches the local environment — the filesystem, external
# processes, or the command line — can run under Rakudo on the reader's machine
# but not in the sandboxed in-browser engine. That's the *online* nature, not a
# Raku++ bug, so these get their own verdict and a distinct note.
# Concurrency: the in-browser engine (Raku.js) is single-threaded WASM, so real
# parallelism deadlocks (await blocks the only thread). Flagged with its own note.
CONCURRENCY_RE = re.compile(
    r"\b(start|await|Promise|Supply|Channel|Thread|react|whenever|Lock)\b")

ENV_RE = re.compile(r"""
      (?<![\w$@%])dir\b          # dir() directory listing (not a $dir variable)
    | \bslurp\b | \bspurt\b
    | \bopen\s*[(:]              # open a file handle
    | \bunlink\b | \brename\b | \bmkdir\b | \brmdir\b | \bchdir\b | \bsymlink\b
    | \bcopy\s*\(
    | \brun\b | \bshell\b | \bQX\b | \bqqx\b
    | \@\*ARGS | \%\*ENV | \$\*CWD
    | \.IO\b                     # IO::Path filesystem operations
""", re.X)

_cache = None

def _load_cache():
    global _cache
    if _cache is None:
        try:
            with open(CACHE_PATH) as f:
                data = json.load(f)
            _cache = data.get("verdicts", {}) if data.get("version") == CACHE_VERSION else {}
        except Exception:
            _cache = {}
    return _cache

def save_cache():
    if _cache is not None:
        with open(CACHE_PATH, "w") as f:
            json.dump({"version": CACHE_VERSION, "verdicts": _cache},
                      f, indent=0, sort_keys=True)


def _run(exe, path, cwd):
    try:
        p = subprocess.run([exe, path], input=b"", capture_output=True,
                           timeout=TIMEOUT, cwd=cwd)
        return dict(out=p.stdout.decode("utf-8", "replace"),
                    err=p.stderr.decode("utf-8", "replace"),
                    rc=p.returncode, to=False)
    except subprocess.TimeoutExpired:
        return dict(out="", err="", rc=None, to=True)
    except FileNotFoundError:
        return dict(out="", err="MISSING", rc=None, to=False, missing=True)

def _compiles(path, cwd):
    try:
        p = subprocess.run([RAKUDO, "-c", path], input=b"", capture_output=True,
                           timeout=TIMEOUT, cwd=cwd)
        return p.returncode == 0
    except subprocess.TimeoutExpired:
        return False
    except FileNotFoundError:
        return None  # rakudo missing → cannot verify


def classify_code(code):
    """Return {'state': 'run'|'fragment'|'rakupp', 'reason': str, ...}."""
    with tempfile.TemporaryDirectory() as d:
        path = os.path.join(d, "prog.raku")
        with open(path, "w") as f:
            f.write(code)

        ok = _compiles(path, d)
        if ok is None:
            return dict(state="run", reason="rakudo unavailable (unverified)")
        if not ok:
            return dict(state="fragment", reason="does not compile (Rakudo -c)")

        # Environment-dependent (filesystem / process / command line): valid under
        # Rakudo locally, but the browser sandbox has no such environment. Not a
        # Raku++ bug — flagged before running so the temp-dir result can't mislead.
        if ENV_RE.search(code):
            return dict(state="env", reason="reads the local environment")
        # Concurrency deadlocks the single-threaded in-browser engine — don't run
        # it (it would hang), just flag it with the concurrency note.
        if CONCURRENCY_RE.search(code):
            return dict(state="concurrent", reason="uses concurrency (promises/threads)")

        r1 = _run(RAKUDO, path, d)
        if r1["to"]:
            return dict(state="fragment", reason="Rakudo run timed out")
        if r1["rc"] != 0:
            return dict(state="fragment", reason="Rakudo runtime error")
        # A program that prints nothing is a useless Run demo (it needs files,
        # args, or input the browser can't give — e.g. `dir(test => /\.jpg$/)` in
        # an empty directory). No visible output ⇒ no Run button.
        if not r1["out"].strip():
            return dict(state="fragment", reason="produces no output to show")
        r2 = _run(RAKUDO, path, d)
        deterministic = (not r2["to"] and r2["rc"] == 0 and r2["out"] == r1["out"])

        p = _run(RAKUPP, path, d)
        if p.get("missing"):
            return dict(state="run", reason="Raku++ unavailable (unverified)")
        if p["to"]:
            return dict(state="rakupp", reason="Raku++ timed out")
        rakupp_err = bool(ERR_RE.search((p["out"] or "") + "\n" + (p["err"] or "")))

        if deterministic:
            if p["out"] == r1["out"] and not rakupp_err:
                return dict(state="run", reason="verified: outputs match")
            return dict(state="rakupp", reason="Raku++ output differs",
                        expected=r1["out"][:300], got=p["out"][:300],
                        err=p["err"][:200])
        # Non-deterministic (rand/pick/time): can't compare values, so accept if
        # Raku++ ran cleanly and produced output.
        if not rakupp_err and p["out"].strip():
            return dict(state="run", reason="non-deterministic; Raku++ ran")
        return dict(state="rakupp", reason="Raku++ error (non-deterministic)",
                    err=(p["err"] or p["out"])[:200])


def get_verdict(code):
    """Cached classify_code, keyed by the exact code text."""
    cache = _load_cache()
    key = hashlib.sha1(code.encode("utf-8")).hexdigest()
    if key not in cache:
        cache[key] = classify_code(code)
    return cache[key]
