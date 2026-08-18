# Andrew Shitov’s Raku Books — browsable, runnable edition

A single static site that turns Andrew Shitov’s Raku/Perl 6 books (published only
as PDFs in [github.com/ash/books](https://github.com/ash/books)) into a browsable
site modelled on [course.raku.org](https://course.raku.org): one page per topic,
breadcrumbs and prev/next navigation, full-text search, light/dark themes, a
book switcher — and **every Raku code example runs in the browser** via Raku.js.

## How it works

Two stages:

1. **Extract** — `tools/extract.py` reads a book PDF with PyMuPDF and rebuilds its
   structure and content from font sizes/faces (headings, prose, code, output),
   writing one `<slug>/…/index.md` per topic plus a `tools/toc-<slug>.yaml`
   fragment. Per-book settings live in `tools/books.yaml`.
2. **Generate** — `raku-books.raku` (adapted from the Raku Course’s
   `raku-pages.raku`) renders the Markdown tree into the static site in `_out/`,
   reading the combined table of contents from `_data/toc/en.yaml`.

The site scaffolding — CSS, search, theme switcher — is reused from the course.
The runnable-code engine is **not** bundled: each page loads the Raku.js widget
and its ~5 MB WASM straight from [raku.online](https://raku.online) (a single
`<script src="https://raku.online/raku.js">`), so the repo carries no WASM.

### Toolchain (Raku where possible)

Fittingly for a site about Raku, the tooling is mostly Raku: the generator
(`raku-books.raku`), the TOC/register assembler (`tools/assemble.raku`), and the
deploy rebaser (`tools/rebase.raku`). Two steps stay in Python because they rely
on libraries with no Raku equivalent: `tools/extract.py` (PyMuPDF — PDF text with
per-span font/size/position, the basis of the heading detection) and
`tools/covers.py` (PyMuPDF page rasterization + Pillow). `tools/verify.py` runs
alongside the extractor (it decides each block's Run-button verdict inline).

## Build

```sh
# 1. Extract a book (key from tools/books.yaml) → <slug>/ + toc fragment +
#    register-<slug>.json. --verify (default) decides Run buttons; see below.
python3 tools/extract.py using-raku

# 2. Render its cover (page 1 of the PDF) → assets/covers/<slug>.jpg
python3 tools/covers.py using-raku

# 3. Merge fragments → _data/toc/en.yaml, and build the Tested-programs register
raku tools/assemble.raku

# 4. Generate the site into _out/
raku raku-books.raku --highlighter=rakupp       # colour code at build time
#   --highlighter=pygments      use Pygments instead (needs `pygmentize`)
#   --highlighter=none          fast, but non-runnable blocks stay uncoloured

# 5. Serve _out/ as the web root
cd _out && python3 -m http.server 8000          # → http://localhost:8000/
```

The book **originals are not in this repo** — the extracted Markdown under each
`<slug>/` is enough to rebuild the site, so steps 1–2 (which need the source
PDF/DOCX) are only for re-extraction. Get the originals from
[github.com/ash/books](https://github.com/ash/books) and point
`tools/books.yaml`'s `books_root` (and the absolute `.docx` paths) at your clone.

## Deployment

The live site is hosted at **andrewshitov.com/raku-books**, served by nginx from
the built `_out/`. The pages use root-absolute links, so before deploying under a
sub-path, run the rebaser:

```sh
raku tools/rebase.raku _out /raku-books
```

It prefixes every `/assets/…` and `/…/` link (and the search index) with
`/raku-books`. The runtime assets resolve themselves — `raku.js` loads its WASM
relative to its own `<script src>`, and `search.js` derives the base from the
`course.css` link — so nothing else needs touching. nginx just points a
`location /raku-books/` at `_out/` (the committed `_out` is already rebased).

Build **with a highlighter** (`rakupp` or `pygments`): runnable blocks are
coloured live by Raku.js, but the no-Run blocks (fragments, Raku++ gaps) rely on
the build-time highlighter, so `--highlighter=none` leaves them plain.

## Which code blocks get a Run button

The Run button (Raku.js in the browser) should appear only for a **complete
program the in-browser engine can actually run**. `tools/verify.py` decides this
at build time by compiling and running each Raku block under two compilers and
tagging the fence the extractor emits:

| Verdict | Fence | Reader sees | How it's detected |
|---|---|---|---|
| **Runnable** | `` ```raku `` | Run button | Rakudo runs it **and** Raku++ reproduces the same output |
| **Fragment** | `` ```raku-static `` | highlighted, Copy only | fails `raku -c` — not a standalone program (partial listing / reuses an earlier variable); or produces no output |
| **Needs local env** | `` ```raku-local `` | Copy + a note | uses the filesystem, a process, or the command line (`dir`, `slurp`, `run`, `@*ARGS`…) — runs locally, but the browser sandbox has no such environment |
| **Raku++ gap** | `` ```raku-nobrowser `` | Copy + a note | Rakudo runs it, but Raku++ errors or prints something different |

Every no-Run block still gets a **Copy** button; runnable blocks get theirs from
the Raku.js editor. Verdicts cache by code hash in `tools/verdict-cache.json`,
versioned so a change to the logic auto-invalidates the cache.

Non-deterministic programs (`rand`, `pick`, time) are detected by running Rakudo
twice; they stay runnable if Raku++ runs them cleanly. The `RAKUPP` env var
points at the Raku++ binary (default: the local arm64 build).

The full picture is published on the site itself at **/tested-programs/** (linked
in the footer): a summary, the Raku++ punch-list (valid programs the browser
engine can't run yet — worth reporting upstream), and the verified-runnable list.

Covers are rendered from page 1 of each PDF and shown on the home card and the
book's landing page.

## Structure mapping

A book’s heading hierarchy maps onto the generator’s Part → Subpart → Section →
Topic levels:

| Book element              | Generator level | Example URL                         |
|---------------------------|-----------------|-------------------------------------|
| Book                      | Part            | `/using-raku/`                      |
| Chapter                   | Subpart         | (grouping; not a URL segment)       |
| Sub-section               | Section         | `/using-raku/using-strings/`        |
| Challenge / topic         | Topic           | `/using-raku/using-strings/string-length/` |

A chapter without sub-sections lists its challenges as sections directly
(`/using-raku/current-date-and-time/`).

## Books and sources

Books appear newest-first on the home page (by the `date:` field). Each has an
`extract.py` source path chosen by content, all feeding the same Node tree +
`emit()`:

| Book | Source | Notes |
|------|--------|-------|
| **The Raku Course** | `static: true` | placeholder card linking to [course.raku.org](https://course.raku.org); hand-written landing + fragment |
| **Raku One-Liners** (2019) | PDF | clean text; Chapter→topic |
| **Using Raku** (2019) | PDF | 100 challenges; shows the *Using Perl 6* 1st-edition cover too |
| **Creating a Compiler in Raku** (2018) | **.docx** | Heading3/4/5 headings, TIFF diagrams extracted → PNG; still under proofreading (`banner:`) |
| **Perl 6 Calendar 2019** | PDF, `source: calendar` + `gallery: true` | 12 month pages: image + a runnable version of the puzzle; landing is a thumbnail gallery |
| **Perl 6 at a Glance** (2017) | **.docx** | the PDF's code font conflates space and `!`, so text comes from the Word file (`cover_pdf` supplies the cover) |
| **Migrating to Raku** | **Markdown**, `source: markdown` | written as Markdown, so nothing is recovered: `md_root` points at the manuscript repo and `manifest.txt` gives the reading order. `unlisted: true` — built and reachable, but absent from every index |

The extractor picks the path from the config: `source: markdown` →
`build_markdown` (a manuscript that is already Markdown — the book's
`manifest.txt` gives the reading order, each book part becomes a TOC grouping and
each chapter one page, and only the code fences are rewritten so Raku blocks earn
their Run-button verdicts), `source: calendar` → `build_calendar`, a `.docx`
source → `build_docx` (heading styles configurable per book; `Code` → code,
`HTMLPreformatted`/`Cmdline` → output, `CodeChar` runs → inline code, embedded
images extracted), `static: true` → skipped (hand-written), otherwise the PDF
`build` (font-size heading detection).

### Unlisted books

`unlisted: true` builds a book and serves it at its URL, but keeps it out of the
home page, the shelf statistics, the book switcher, the search index, and the
Tested-programs register — for a book that is readable online before it is
announced. Remove the flag (and rebuild) to publish it.

### Perl blocks

A migration book quotes as much Perl as Raku. A ` ```perl ` fence renders with a
steel-blue rule and a small **Perl** label (`.highlight.perl-code`) so it reads
as neither Raku nor program output, and never carries a Run button — the
in-browser engine runs Raku. Under `--highlighter=pygments` it is syntax-coloured
as Perl; `rakupp` is a Raku lexer, so under it Perl blocks stay plain.

## Run-button verdicts, recap

Each Raku block is compiled/run under Rakudo and Raku++ at build time and tagged
(`tools/verify.py`): **runnable** (Run button), **fragment** (no Run),
**needs local env** (files/CLI), **concurrency** (promises/threads — the
single-threaded in-browser engine deadlocks on these), or **Raku++ gap**. The
full breakdown is published at `/tested-programs/`.
