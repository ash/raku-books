#!/usr/bin/env python3
"""
extract.py — turn one of Andrew Shitov's Raku book PDFs into the Markdown +
TOC tree that raku-books.raku consumes.

The books have no manuscript source, so structure and content are recovered from
the PDF itself:

  * Structure comes from font *size* — every book sets headings in the same
    Revival565BT family at distinct sizes (see books.yaml `levels`):
        chapter  (e.g. 48pt, "Strings")
        section  (e.g. 25.9pt, "1.1 Using strings")
        topic    (e.g. 22.1pt, "3. String length")  ← leaf content page
    Sizes to ignore (labels/grouping) are listed in `drop_sizes`.
  * Body text is Revival565BT (~11pt); code is Consolas (~10pt); program output
    is an italic monospace/Arial face. Lines are classified by their dominant
    font, blocks are rebuilt from vertical gaps, and prose is de-hyphenated.

Output: one `<slug>/…/index.md` per node under the book's slug dir, plus a YAML
fragment `tools/toc-<slug>.yaml` describing the book's branch of the global TOC.

Usage:  python3 tools/extract.py <book-key>        # key from books.yaml
        python3 tools/extract.py <book-key> --probe # just print detected sizes
"""

import argparse, json, os, re, sys
from collections import Counter

import fitz  # PyMuPDF
import yaml

import verify  # build-time Run-button verdicts (Rakudo vs Raku++)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Collected during a --verify run: one entry per runnable-candidate Raku block,
# {state, reason, label, first} — used for the end-of-run report and punch-list.
VERDICTS = []
# Fence that carries each verdict through to the generator:
#   raku            → runnable (Run button)
#   raku-static     → fragment: highlighted, no Run, no note
#   raku-nobrowser  → valid but Raku++ can't run it: no Run + a Raku++-gap note
#   raku-local      → needs the local environment (files/CLI): no Run + a local note
FENCE = {"run": "raku", "fragment": "raku-static",
         "rakupp": "raku-nobrowser", "env": "raku-local",
         "concurrent": "raku-async"}


# ─────────────────────────── line model ────────────────────────────────

class Line:
    __slots__ = ("text", "spans", "y0", "y1", "x0", "size", "font", "cls", "page")

    def __init__(self, spans, page=0):
        # Strip stray control characters (0x00–0x1F except tab/newline, and DEL):
        # some PDF fonts map exotic operators/glyphs (⊂, Unicode digits, …) to
        # control codepoints, which otherwise render as garbage and break JSON.
        for s in spans:
            s["text"] = re.sub(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]", "", s["text"])
        self.spans = spans
        self.page = page
        self.text = "".join(s["text"] for s in spans)
        self.y0 = min(s["bbox"][1] for s in spans)
        self.y1 = max(s["bbox"][3] for s in spans)
        self.x0 = min(s["bbox"][0] for s in spans)
        fc = Counter()
        for s in spans:
            fc[(round(s["size"], 1), s["font"])] += max(len(s["text"]), 1)
        (self.size, self.font) = fc.most_common(1)[0][0]
        self.cls = None  # filled by classify()


def page_lines(page, pnum=0):
    out = []
    for b in page.get_text("dict")["blocks"]:
        if "lines" not in b:
            continue
        for l in b["lines"]:
            spans = [s for s in l["spans"] if s["text"]]
            if not spans:
                continue
            ln = Line(spans, pnum)
            if ln.text.strip():
                out.append(ln)
    out.sort(key=lambda l: (round(l.y0), l.x0))
    return out


# ─────────────────────────── classification ────────────────────────────

def is_code_font(font):
    return "Consolas" in font or "Courier" in font or "Mono" in font

def is_output_font(font):
    # Program output / captions: italic monospace, or the italic Arial the
    # books use for inline results and console transcripts.
    return ("Consolas-Italic" in font
            or (("Arial" in font or "Helvetica" in font) and "Italic" in font))

def is_prose_font(font):
    # The body/serif faces used for running text (and, italic, for task lines).
    return ("Revival" in font or "Georgia" in font or "Times" in font
            or "Minion" in font or "Garamond" in font or "Serif" in font)


def near(size, target, tol=0.4):
    return abs(size - target) <= tol

def classify(ln, cfg):
    """Tag a line: ('heading', level) | 'code' | 'output' | 'prose' | 'prose_i'.

    A line counts as code/output only if that font dominates *most* of its
    characters — a prose line that merely contains a lot of inline code (e.g.
    "[+] @data is equivalent to @data[0] + @data[1] …") stays prose, so it is not
    swallowed into the code block."""
    size = ln.size
    if any(near(size, s) for s in cfg.get("drop_sizes", [])):
        return ("drop", None)
    for level, sizes in cfg["levels"].items():
        if any(near(size, s) for s in sizes):
            return ("heading", level)

    total = sum(len(s["text"]) for s in ln.spans) or 1
    prose_ch = sum(len(s["text"]) for s in ln.spans if is_prose_font(s["font"]))
    code_ch = sum(len(s["text"]) for s in ln.spans
                  if is_code_font(s["font"]) and not is_output_font(s["font"]))
    out_ch = sum(len(s["text"]) for s in ln.spans if is_output_font(s["font"]))

    # Any real body-font content → prose (a paragraph that merely quotes a lot of
    # inline code still reads as prose). Code lines carry no body font.
    if prose_ch / total >= 0.35:
        return ("prose_i" if "Italic" in ln.font else "prose", None)
    # No body font. A line with real code font is a code line — this is what keeps
    # the program's final `say @list; # [3 3 …]` (Consolas code + italic-Arial
    # output comment, no body font) part of the runnable block instead of prose.
    if code_ch > 0:
        return ("code", None)
    # Only the italic output/result face → program output (non-runnable).
    if out_ch > 0:
        return ("output", None)
    return ("prose", None)


# ─────────────────────────── text helpers ──────────────────────────────

def slugify(text):
    t = text.strip().lower()
    t = re.sub(r"^\s*\d+(\.\d+)*\.?\s*", "", t)      # drop "3." / "1.1." label
    t = t.replace("’", "").replace("'", "")
    t = re.sub(r"[^a-z0-9]+", "-", t)
    t = re.sub(r"-+", "-", t).strip("-")
    return t or "page"

def clean_heading(text):
    """Display title: collapse whitespace, keep a challenge's leading number."""
    return re.sub(r"\s+", " ", text).strip()

def strip_section_number(text):
    # Section titles arrive as "1.1 Using strings" (number on its own line first);
    # drop a bare leading "N.N" label.
    return re.sub(r"^\s*\d+(\.\d+)*\.?\s+", "", clean_heading(text))


def inline_markup(ln):
    """Render a prose line to Markdown, wrapping runs of code-font spans in
    backticks so inline code the author set in Consolas stays monospace."""
    out = []
    buf = []  # pending code-span text
    def flush():
        if buf:
            raw = "".join(buf)
            code = raw.strip()
            if code:
                # keep any boundary space OUTSIDE the backticks so inline code
                # never runs into the neighbouring word (`'Hello',` and …).
                lead = " " if raw[:1].isspace() else ""
                trail = " " if raw[-1:].isspace() else ""
                out.append(f"{lead}`{code}`{trail}")
            buf.clear()
    for s in ln.spans:
        if is_code_font(s["font"]) and not is_output_font(s["font"]):
            buf.append(s["text"])
        else:
            flush()
            out.append(s["text"])
    flush()
    return "".join(out)


# ─────────────────────────── block assembly ────────────────────────────

def dehyphenate(prev, nxt):
    """Join two prose fragments, removing a soft hyphen at a line break."""
    p = prev.rstrip()
    if p.endswith("-") and len(p) >= 2 and p[-2].isalpha() and nxt[:1].isalpha():
        return p[:-1] + nxt.lstrip()
    if not p:
        return nxt.lstrip()
    return p + " " + nxt.lstrip()


LINE_H = 16.0  # nominal body line height; gaps larger than PARA_GAP break blocks

# A code-font block is treated as a runnable Raku program only if it shows some
# Raku syntax. Program *output* is often set in the same upright monospace font
# (e.g. "Hello, World!" printed under "The output is:"), so without this it would
# wrongly get a Run button. Blocks failing this become plain ``` (non-runnable).
_RAKU_KW = re.compile(r"\b(say|print|put|note|my|our|state|has|sub|method|multi|"
                      r"for|while|until|loop|repeat|if|unless|given|when|return|"
                      r"use|need|class|role|grammar|token|rule|regex|enum|constant|"
                      r"die|try|gather|take|start|await|react|whenever|map|grep)\b")
def looks_like_raku(code):
    return bool(re.search(r"[\$\@\%&]", code)   # a sigil
                or ";" in code                  # a statement terminator
                or _RAKU_KW.search(code))       # a Raku keyword


def fenced_code(kind, body, cfg, label="", url=""):
    """Fence one code/output block, choosing the Run-button verdict via verify.py.
    Shared by the PDF and DOCX extractors so both get identical Run-button logic."""
    body = body.rstrip()
    first = body.lstrip().split("\n", 1)[0]
    # A shell/REPL transcript (`$ raku …`, `> …`) is a console session, not a
    # runnable program — "$ " has a space, unlike a Raku `$var`.
    is_console = first.startswith("$ ") or first.startswith("> ")
    if kind == "code" and not is_console and looks_like_raku(body):
        fence = "raku"
        if cfg.get("verify"):
            v = verify.get_verdict(body)
            fence = FENCE[v["state"]]
            VERDICTS.append(dict(state=v["state"], reason=v.get("reason", ""),
                                 label=label, url=url, first=first[:70]))
        return f"```{fence}\n{body}\n```"
    return f"```\n{body}\n```"          # output/console → non-runnable

def blocks_to_md(lines, cfg, label="", url=""):
    """Convert a node's content lines (already in reading order) to Markdown."""
    md = []
    i, n = 0, len(lines)
    para_gap = cfg.get("para_gap", 22.0)
    while i < n:
        ln = lines[i]
        if ln.cls[0] in ("code", "output"):
            kind = ln.cls[0]
            chunk = [ln]
            j = i + 1
            while j < n and lines[j].cls[0] == kind:
                gap = lines[j].y0 - lines[j - 1].y0   # top-to-top
                if gap > 2.6 * LINE_H:            # too far → separate block
                    break
                chunk.append(lines[j])
                j += 1
            code_lines = []
            for k, c in enumerate(chunk):
                if k > 0:
                    gap = c.y0 - chunk[k - 1].y0
                    if gap > 1.6 * LINE_H:        # preserve a blank line in code
                        code_lines.append("")
                code_lines.append(c.text.rstrip())
            body = "\n".join(code_lines).rstrip()
            md.append(fenced_code(kind, body, cfg, label, url))
            i = j
        else:  # prose / prose_i paragraph
            italic = ln.cls[0] == "prose_i"
            text = inline_markup(ln)
            j = i + 1
            while j < n and lines[j].cls[0] in ("prose", "prose_i"):
                # don't merge an italic task-line with following roman prose
                if (lines[j].cls[0] == "prose_i") != italic:
                    break
                if lines[j].page != lines[j - 1].page:
                    # y-coords reset each page; a paragraph flows across the break
                    # unless the previous line clearly ended a sentence.
                    if re.search(r'[.!?:"”]\s*$', text):
                        break
                else:
                    gap = lines[j].y0 - lines[j - 1].y0   # top-to-top baseline delta
                    if gap > para_gap:
                        break
                text = dehyphenate(text, inline_markup(lines[j]))
                j += 1
            text = re.sub(r"\s+", " ", text).strip()
            if text:
                md.append(f"*{text}*" if italic else text)
            i = j
    return "\n\n".join(md).strip()


# ─────────────────────────── tree building ─────────────────────────────

class Node:
    def __init__(self, level, title, slug):
        self.level = level          # 'chapter' | 'section' | 'topic'
        self.title = title
        self.slug = slug
        self.lines = []             # content lines (PDF source)
        self.blocks = []            # (kind, text) blocks (DOCX source)
        self.thumb = None           # thumbnail image path (gallery landings)
        self.children = []


def build(cfg):
    doc = fitz.open(cfg["_pdfpath"])
    first = cfg.get("first_page", 1) - 1
    last = cfg.get("last_page", doc.page_count) - 1

    book = Node("book", cfg["title"], cfg["slug"])
    # `real_section` distinguishes a genuine sub-section heading from a challenge
    # that was promoted to section level (in a chapter that has no sub-sections).
    # Only a real sub-section adopts the following challenges as its topics; a
    # promoted challenge does not, so sibling challenges stay siblings.
    cur = {"chapter": None, "section": None, "topic": None, "real_section": False}
    used_slugs = set()

    def uniq(slug):
        s, k = slug, 2
        while s in used_slugs:
            s = f"{slug}-{k}"; k += 1
        used_slugs.add(s)
        return s

    def ensure_chapter():
        if cur["chapter"] is None:
            ch = Node("chapter", cfg.get("intro_title", "Introduction"),
                      uniq("introduction"))
            book.children.append(ch)
            cur["chapter"] = ch
        return cur["chapter"]

    def target():
        return cur["topic"] or cur["section"] or cur["chapter"] or book

    def open_heading(level, raw_lines):
        joined = clean_heading(" ".join(raw_lines))
        if level == "chapter":
            # Some books set "Chapter N" in the same size as the chapter title, so
            # it merges into `joined`; drop that leading label ("Chapter 1 Working
            # with Files" → "Working with Files"). Books that don't use it are
            # unaffected ("Preface", "Appendix on Compiler Internals").
            title = re.sub(r"^Chapter\s+\d+\s+", "", strip_section_number(joined))
            ch = Node("chapter", title, uniq(slugify(title)))
            book.children.append(ch)
            cur.update(chapter=ch, section=None, topic=None, real_section=False)
        elif level == "section":
            ch = ensure_chapter()
            title = strip_section_number(joined)
            sec = Node("section", title, uniq(slugify(title)))
            ch.children.append(sec)
            cur.update(section=sec, topic=None, real_section=True)
        else:  # topic (challenge)
            ch = ensure_chapter()
            title = joined  # keep the challenge number in the title
            if cur["section"] is not None and cur["real_section"]:
                top = Node("topic", title, uniq(slugify(title)))
                cur["section"].children.append(top)
                cur["topic"] = top
            else:
                # no real sub-section in this chapter → each challenge is its own
                # section (siblings under the chapter), never nested in a peer.
                sec = Node("section", title, uniq(slugify(title)))
                ch.children.append(sec)
                cur.update(section=sec, topic=None, real_section=False)

    hdr_pat = [re.compile(p) for p in cfg.get("strip_lines", [])]
    pending = None  # [level, [lines...], last_y1]

    for pnum in range(first, last + 1):
        for ln in page_lines(doc[pnum], pnum):
            t = ln.text.strip()
            if re.fullmatch(r"\d{1,4}", t):
                continue
            if any(p.search(t) for p in hdr_pat):
                continue
            ln.cls = classify(ln, cfg)
            kind, level = ln.cls
            if kind == "drop":
                continue
            if kind == "heading":
                if pending and pending[0] == level and (ln.y0 - pending[2]) < 3 * LINE_H:
                    pending[1].append(ln.text); pending[2] = ln.y1
                else:
                    if pending:
                        open_heading(pending[0], pending[1])
                    pending = [level, [ln.text], ln.y1]
                continue
            if pending:
                open_heading(pending[0], pending[1])
                pending = None
            target().lines.append(ln)
    if pending:
        open_heading(pending[0], pending[1])

    return book


# ─────────────────────────── DOCX source ───────────────────────────────
# A .docx keeps clean text and semantic paragraph styles, so it sidesteps the
# PDF font problems entirely (e.g. Perl 6 at a Glance, whose PDF code font maps
# space and "!" to the same glyph). Styles map: Heading1/2/3 → chapter/section/
# topic, Code → runnable code, HTMLPreformatted → output, CodeChar runs → inline
# code. The result is the same Node tree the PDF path builds, so emit() is shared.

import html as _htmllib

def _para_style(p):
    m = re.search(r'<w:pStyle w:val="([^"]+)"', p)
    return m.group(1) if m else ""

def _para_segments(p):
    """(text, is_inline_code) for each run, with tabs/breaks preserved."""
    segs = []
    for r in re.findall(r'<w:r\b.*?</w:r>', p, re.S):
        is_code = bool(re.search(r'<w:rStyle w:val="[^"]*Code[^"]*"', r))
        parts = []
        for m in re.finditer(r'<w:t[^>]*>(.*?)</w:t>|<w:tab\b[^>]*/?>|<w:br\b[^>]*/?>|<w:cr\b[^>]*/?>',
                             r, re.S):
            g = m.group(0)
            if g.startswith("<w:tab"):
                parts.append("    ")
            elif g.startswith("<w:br") or g.startswith("<w:cr"):
                parts.append("\n")
            else:
                parts.append(_htmllib.unescape(m.group(1)))
        t = "".join(parts)
        if t:
            segs.append((t, is_code))
    return segs

def _docx_plain(p):
    return "".join(t for t, _ in _para_segments(p))

def _docx_markdown(p):
    """Prose Markdown, wrapping inline-code runs in backticks (boundary space kept
    outside the backticks so code never abuts the neighbouring word)."""
    out, buf = [], []
    def flush():
        if buf:
            code = "".join(buf)
            s = code.strip()
            if s:
                lead = " " if code[:1].isspace() else ""
                trail = " " if code[-1:].isspace() else ""
                out.append(f"{lead}`{s}`{trail}")
            buf.clear()
    for t, is_code in _para_segments(p):
        if is_code:
            buf.append(t)
        else:
            flush(); out.append(t)
    flush()
    return "".join(out)


def build_docx(cfg):
    import zipfile
    slug = cfg["slug"]
    with zipfile.ZipFile(cfg["_pdfpath"]) as z:
        xml = z.read("word/document.xml").decode("utf-8", "replace")
        rels = ""
        try:
            rels = z.read("word/_rels/document.xml.rels").decode("utf-8", "replace")
        except KeyError:
            pass
        # rId → web path: extract each embedded image, convert to PNG under
        # assets/<slug>/, so diagrams (often TIFF) display in the browser.
        img_map = {}
        rid_target = dict(re.findall(r'Id="([^"]+)"[^>]*Target="([^"]*media[^"]*)"', rels))
        if rid_target:
            from PIL import Image as _Img
            import io as _io
            out_dir = os.path.join(ROOT, "assets", slug)
            os.makedirs(out_dir, exist_ok=True)
            for rid, target in rid_target.items():
                name = os.path.splitext(os.path.basename(target))[0] + ".png"
                try:
                    data = z.read("word/" + target)
                    im = _Img.open(_io.BytesIO(data)).convert("RGB")
                    if im.width > 820:
                        im = im.resize((820, round(im.height * 820 / im.width)), _Img.LANCZOS)
                    im.save(os.path.join(out_dir, name), "PNG")
                    img_map[rid] = f"/assets/{slug}/{name}"
                except Exception:
                    pass
    paras = re.findall(r'<w:p\b.*?</w:p>', xml, re.S)

    book = Node("book", cfg["title"], slug)
    cur = {"chapter": None, "section": None, "topic": None, "real_section": False}
    used = set()

    def uniq(slug):
        s, k = slug, 2
        while s in used:
            s = f"{slug}-{k}"; k += 1
        used.add(s); return s

    def ensure_chapter():
        if cur["chapter"] is None:
            ch = Node("chapter", cfg.get("intro_title", "Introduction"), uniq("introduction"))
            book.children.append(ch); cur["chapter"] = ch
        return cur["chapter"]

    def target():
        return cur["topic"] or cur["section"] or cur["chapter"] or book

    def open_heading(level, title):
        title = re.sub(r"^Chapter\s+\d+\.?\s*", "", strip_section_number(title))
        if level == "chapter":
            ch = Node("chapter", title, uniq(slugify(title))); book.children.append(ch)
            cur.update(chapter=ch, section=None, topic=None, real_section=False)
        elif level == "section":
            ch = ensure_chapter()
            sec = Node("section", title, uniq(slugify(title))); ch.children.append(sec)
            cur.update(section=sec, topic=None, real_section=True)
        else:  # topic
            ch = ensure_chapter()
            if cur["section"] is not None and cur["real_section"]:
                top = Node("topic", title, uniq(slugify(title)))
                cur["section"].children.append(top); cur["topic"] = top
            else:
                sec = Node("section", title, uniq(slugify(title))); ch.children.append(sec)
                cur.update(section=sec, topic=None, real_section=False)

    # Which Word heading styles map to chapter/section/topic (books differ:
    # Perl 6 at a Glance uses Heading1/2/3, the compiler book Heading3/4/5).
    STYLE = cfg.get("heading_styles",
                    {"Heading1": "chapter", "Heading2": "section", "Heading3": "topic"})
    # Console/command-line styles render as non-runnable output.
    OUT_STYLES = set(cfg.get("output_styles", ["HTMLPreformatted", "Cmdline"]))
    code_buf, out_buf = [], []
    def flush_code():
        if code_buf:
            target().blocks.append(("code", "\n".join(code_buf).rstrip())); code_buf.clear()
    def flush_out():
        if out_buf:
            target().blocks.append(("output", "\n".join(out_buf).rstrip())); out_buf.clear()
    def flush():
        flush_code(); flush_out()

    started = False   # skip the title page / printed TOC before the first heading
    for p in paras:
        st = _para_style(p)
        if st.startswith("TOC"):
            continue
        if st in STYLE:
            flush()
            t = _docx_plain(p).strip()
            if not t or t.lower() in ("contents", "table of contents"):
                continue                       # the printed TOC heading, not a chapter
            started = True
            open_heading(STYLE[st], t)
        elif not started:
            continue
        elif st == "Code":
            flush_out(); code_buf.append(_docx_plain(p).rstrip())
        elif st in OUT_STYLES:
            flush_code(); out_buf.append(_docx_plain(p).rstrip())
        elif st == "Codeinheader":
            continue
        else:  # prose, and/or an embedded image (a diagram)
            flush()
            embeds = re.findall(r'r:embed="([^"]+)"', p)
            for rid in embeds:
                if rid in img_map:
                    target().blocks.append(("prose", f"![diagram]({img_map[rid]})"))
            t = _docx_markdown(p).strip()
            if t:
                target().blocks.append(("prose", t))
    flush()
    return book


# ─────────────────────────── Calendar source ───────────────────────────
# The Perl 6 Calendar is 12 designed A3 pages (one per month), each a picture +
# a mini calendar grid + a code puzzle. We render each page to an image and show
# it with the puzzle's code beneath — no prose model applies.

CAL_MONTHS = ["January", "February", "March", "April", "May", "June", "July",
              "August", "September", "October", "November", "December"]

# The puzzle code printed on each calendar page is stylised (typographic ×, ², −,
# and variables like $r/@data/$month left undefined) so it doesn't run as-is. The
# image keeps that pretty form; below it we show a runnable Raku version, with the
# variables set and the symbols normalised, so the reader can actually run it.
CAL_CODE = {
    "january":   "say [*] 1..2019",
    "february":  "say ((1..*).grep: *.is-prime)[2018]",
    "march":     "my $r = 5;\nsay pi * $r ** 2",
    "april":     ("my @data = 5, 3, 1, 4, 2;\n"
                  "await gather for @data -> $d {\n"
                  "    take start {\n        sleep $d;\n        say $d;\n    }\n}"),
    "may":       "say ([~] ^2020).comb.sum",
    "june":      "say ('0'..'z').pick(15).join",
    "july":      "say 0.1 + 0.2 - 0.3",
    "august":    "2019.rand.Int.say",
    "september": "my @data = 1, 2, 3;\n@data <<+=>> 2019;\nsay @data",
    "october":   "say DateTime.now.yyyy-mm-dd",
    "november":  "say 1..10 X* 1..10",
    "december":  "my $month = 12;\nsay $month == 1 | 2 | 12",
}

def build_calendar(cfg):
    from PIL import Image
    doc = fitz.open(cfg["_pdfpath"])
    book = Node("book", cfg["title"], cfg["slug"])
    # An empty slug makes this a pure grouping subpart: no landing page and no
    # breadcrumb crumb, so the months sit directly under the book.
    chapter = Node("chapter", cfg.get("intro_title", "Months"), "")
    book.children.append(chapter)

    out_dir = os.path.join(ROOT, "assets", "calendar")
    os.makedirs(out_dir, exist_ok=True)
    max_w = cfg.get("image_width", 820)
    first = cfg.get("first_page", 2) - 1

    for idx, pnum in enumerate(range(first, doc.page_count)):
        page = doc[pnum]
        month = CAL_MONTHS[idx] if idx < len(CAL_MONTHS) else f"Page {pnum + 1}"
        slug = month.lower()

        # Render the whole designed page to an image.
        pix = page.get_pixmap(matrix=fitz.Matrix(1.2, 1.2))
        img = Image.frombytes("RGB", (pix.width, pix.height), pix.samples)
        if img.width > max_w:
            img = img.resize((max_w, round(img.height * max_w / img.width)), Image.LANCZOS)
        img.save(os.path.join(out_dir, f"{slug}.jpg"), "JPEG", quality=82)

        # Pull out the puzzle task (a CenturyGothic sentence, not the grid) and
        # the code (Tajawal font), keeping the code in top-to-bottom order.
        task_lines, code = [], []
        for b in page.get_text("dict")["blocks"]:
            if "lines" not in b:
                continue
            for l in b["lines"]:
                spans = l["spans"]
                t = "".join(s["text"] for s in spans).rstrip()
                if not t.strip():
                    continue
                y0 = min(s["bbox"][1] for s in spans)
                if any("Tajawal" in s["font"] for s in spans):
                    code.append((y0, t))
                elif any(len(w) >= 4 for w in t.split()):   # a real sentence, not the grid
                    task_lines.append((y0, t.strip()))
        task = " ".join(t for _, t in sorted(task_lines))
        # Prefer the curated runnable version; fall back to the extracted code.
        code_text = CAL_CODE.get(slug, "\n".join(t for _, t in sorted(code)).rstrip())

        sec = Node("section", month, slug)
        sec.thumb = f"/assets/calendar/{slug}.jpg"
        # `{.cal-page}` → a class pandoc puts on the <img>, for the thin frame.
        sec.blocks = [("prose", f"![Perl 6 Calendar 2019 — {month}]({sec.thumb}){{.cal-page}}")]
        if task:
            sec.blocks.append(("prose", f"**{task}**"))
        if code_text:
            sec.blocks.append(("code", code_text))
        chapter.children.append(sec)
    return book


# ─────────────────────────── emit md + toc ─────────────────────────────

PAGE_HEAD = "---\ntitle: {title}\n---\n\n{{% include menu.html %}}\n\n"
PAGE_FOOT = "\n\n{% include nav.html %}\n"

def write_page(path, title, body):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    md = PAGE_HEAD.format(title=yaml_title(title)) + body + PAGE_FOOT
    with open(path, "w") as f:
        f.write(md)

def yaml_title(t):
    # titles may contain ':' etc.; the front matter uses it raw, so quote if needed
    return t

def render_blocks(blocks, cfg, label="", url=""):
    """Render a DOCX node's (kind, text) blocks to Markdown. Prose blocks are
    already Markdown; code/output go through the shared fenced_code."""
    md = []
    for kind, text in blocks:
        if kind in ("code", "output"):
            md.append(fenced_code(kind, text, cfg, label, url))
        elif text.strip():
            md.append(text)
    return "\n\n".join(md).strip()


def node_body(node, cfg, url=""):
    if node.blocks:
        return render_blocks(node.blocks, cfg, label=node.title, url=url)
    return blocks_to_md(node.lines, cfg, label=node.title, url=url)


def emit(book, cfg):
    slug = cfg["slug"]
    base = os.path.join(ROOT, slug)
    toc_items = []          # chapters (subparts)

    # Book landing page. A book is a Part, whose landing page the generator does
    # NOT synthesise (only subparts are), so we write it here: the book's own
    # intro prose (if any) followed by {% include toc.html %}, which renders the
    # full chapter/section table of contents (render-part) with the book heading.
    book_intro = node_body(book, cfg, url=f"/{slug}")
    landing = (book_intro + "\n\n" if book_intro else "") + "{% include toc.html %}"
    write_page(os.path.join(base, "index.md"), cfg["title"], landing)

    for ch in book.children:
        ch_entry = dict(title=ch.title, url=ch.slug)
        sec_items = []
        # chapter landing page content (intro prose before first section)
        ch_body = node_body(ch, cfg, url=f"/{slug}/{ch.slug}")
        ch_dir = os.path.join(base, ch.slug)
        # A chapter is a subpart: its landing page is synthesised by the generator,
        # but if it has its own intro prose we still write it so nothing is lost.
        if ch_body:
            write_page(os.path.join(ch_dir, "index.md"), ch.title, ch_body)

        for sec in ch.children:
            sec_entry = dict(title=sec.title, url=sec.slug)
            if sec.thumb:
                sec_entry["thumb"] = sec.thumb
            sec_body = node_body(sec, cfg, url=f"/{slug}/{sec.slug}")
            # Section URL is book/section (subpart not in path), matching the generator.
            sec_path = os.path.join(base, sec.slug, "index.md")
            if sec.children:
                top_items = []
                for top in sec.children:
                    tbody = node_body(top, cfg, url=f"/{slug}/{sec.slug}/{top.slug}")
                    write_page(os.path.join(base, sec.slug, top.slug, "index.md"),
                               top.title, tbody)
                    top_items.append(dict(title=top.title, url=top.slug))
                sec_entry["items"] = top_items
                # section landing: its own intro (if any); nav lists the topics
                write_page(sec_path, sec.title, sec_body)
            else:
                write_page(sec_path, sec.title, sec_body)
            sec_items.append(sec_entry)

        if sec_items:
            ch_entry["items"] = sec_items
        toc_items.append(ch_entry)

    book_entry = dict(title=cfg["title"], url=slug)
    if cfg.get("long_title"):
        book_entry["long_title"] = cfg["long_title"]
    if cfg.get("description"):
        book_entry["description"] = cfg["description"]
    # Cover image slug(s): the book's own plus any extra covers (e.g. an earlier
    # edition). The generator shows each one that has a rendered assets/covers file.
    book_entry["covers"] = [slug] + [e["name"] for e in cfg.get("extra_covers", [])]
    if cfg.get("meta"):
        book_entry["meta"] = cfg["meta"]
    if cfg.get("banner"):
        book_entry["banner"] = cfg["banner"]
    if cfg.get("gallery"):
        book_entry["gallery"] = True
    book_entry["items"] = toc_items

    frag = os.path.join(ROOT, "tools", f"toc-{slug}.yaml")
    with open(frag, "w") as f:
        yaml.dump([book_entry], f, allow_unicode=True, sort_keys=False, width=100)
    return book_entry


# ─────────────────────────── stats / probe ─────────────────────────────

def probe(cfg):
    doc = fitz.open(cfg["_pdfpath"])
    sizes = Counter()
    samples = {}
    for p in range(cfg.get("first_page", 1) - 1, cfg.get("last_page", doc.page_count)):
        for ln in page_lines(doc[p], p):
            sizes[ln.size] += 1
            samples.setdefault(ln.size, ln.text[:50])
    for sz, cnt in sorted(sizes.items(), reverse=True):
        print(f"size={sz:6}  n={cnt:5}  e.g. {samples[sz]!r}")


def count(node):
    ch = len(node.children)
    sec = sum(len(c.children) for c in node.children)
    top = sum(len(s.children) for c in node.children for s in c.children)
    return ch, sec, top


def report_verdicts():
    if not VERDICTS:
        return
    from collections import Counter as C
    tally = C(v["state"] for v in VERDICTS)
    total = len(VERDICTS)
    print(f"\nRun-button verdicts ({total} Raku programs):")
    print(f"  runnable (Run button)  : {tally['run']}")
    print(f"  fragments (no Run)     : {tally['fragment']}")
    print(f"  needs local env (note) : {tally['env']}")
    print(f"  concurrency (note)     : {tally['concurrent']}")
    print(f"  Raku++ gaps (note)     : {tally['rakupp']}")
    gaps = [v for v in VERDICTS if v["state"] == "rakupp"]
    if gaps:
        print("\n  Raku++ punch-list (valid programs the browser engine can't run):")
        for v in gaps:
            print(f"    • [{v['label']}] {v['reason']}: {v['first']}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("book")
    ap.add_argument("--probe", action="store_true")
    ap.add_argument("--verify", dest="verify", action="store_true", default=True,
                    help="decide Run buttons by compiling/running each block (default)")
    ap.add_argument("--no-verify", dest="verify", action="store_false",
                    help="skip verification — mark every complete-looking block runnable")
    args = ap.parse_args()

    with open(os.path.join(ROOT, "tools", "books.yaml")) as f:
        conf = yaml.safe_load(f)
    books = conf["books"]
    if args.book not in books:
        sys.exit(f"unknown book '{args.book}'; known: {', '.join(books)}")
    books_root = os.path.expanduser(conf["books_root"])
    cfg = books[args.book]
    cfg["verify"] = args.verify
    cfg["_pdfpath"] = cfg["pdf"] if os.path.isabs(cfg["pdf"]) \
        else os.path.join(books_root, cfg["pdf"])

    if args.probe:
        probe(cfg)
        return

    if cfg.get("source") == "calendar":
        book = build_calendar(cfg)
    elif cfg["_pdfpath"].lower().endswith(".docx"):
        book = build_docx(cfg)
    else:
        book = build(cfg)
    ch, sec, top = count(book)
    emit(book, cfg)
    if args.verify:
        verify.save_cache()
        reg = os.path.join(ROOT, "tools", f"register-{cfg['slug']}.json")
        with open(reg, "w") as f:
            json.dump({"book": cfg["title"], "slug": cfg["slug"],
                       "verdicts": VERDICTS}, f, indent=1)
    print(f"{cfg['slug']}: {ch} chapters, {sec} sections, {top} topics")
    report_verdicts()


if __name__ == "__main__":
    main()
