#!/usr/bin/env python3
"""
covers.py — render each book's cover (page 1 of its PDF) to assets/covers/<slug>.jpg.

The generator shows the cover on the home-page book card and on the book's
landing page when the file exists (paths keyed by slug), so this just needs to
produce one image per book.

Usage:  python3 tools/covers.py [book-key ...]     # default: all books
"""
import io, os, sys
import fitz
import yaml
from PIL import Image, ImageChops

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ZOOM = 1.6      # render scale for the fallback path
MAX_WIDTH = 760  # downscale target — plenty for the card and landing hero


def trim_white(img, thresh=12):
    """Crop the white page margin the PDF leaves around the cover artwork.
    Only used as a fallback when the cover isn't a single embedded image."""
    bg = Image.new("RGB", img.size, (255, 255, 255))
    diff = ImageChops.difference(img.convert("RGB"), bg).convert("L")
    bbox = diff.point(lambda p: 255 if p > thresh else 0).getbbox()
    return img.crop(bbox) if bbox else img


def cover_image(doc, page):
    """The cover artwork. Prefer the page's embedded image — it has the cover's
    true bounds (trimming the rendered page fails on covers whose own background
    is white, like Raku One-Liners). Fall back to render + trim-white."""
    imgs = page.get_images(full=True)
    if imgs:
        # the largest image on the page is the cover
        xref = max(imgs, key=lambda im: (lambda i: i["width"] * i["height"])
                   (doc.extract_image(im[0])))[0]
        data = doc.extract_image(xref)["image"]
        return Image.open(io.BytesIO(data)).convert("RGB")
    pix = page.get_pixmap(matrix=fitz.Matrix(ZOOM, ZOOM))
    return trim_white(Image.frombytes("RGB", (pix.width, pix.height), pix.samples))

def main():
    with open(os.path.join(ROOT, "tools", "books.yaml")) as f:
        conf = yaml.safe_load(f)
    books = conf["books"]
    root = os.path.expanduser(conf["books_root"])
    keys = sys.argv[1:] or list(books)

    out_dir = os.path.join(ROOT, "assets", "covers")
    os.makedirs(out_dir, exist_ok=True)

    def save(img, name):
        if img.width > MAX_WIDTH:
            img = img.resize((MAX_WIDTH, round(img.height * MAX_WIDTH / img.width)),
                             Image.LANCZOS)
        dst = os.path.join(out_dir, f"{name}.jpg")
        img.convert("RGB").save(dst, format="JPEG", quality=85)
        print(f"  {name}.jpg  {img.width}x{img.height}  ({os.path.getsize(dst)//1024} KB)")

    def render_pdf(pdf_rel, name, cover_page=1):
        pdf = pdf_rel if os.path.isabs(pdf_rel) else os.path.join(root, pdf_rel)
        doc = fitz.open(pdf)
        save(cover_image(doc, doc[cover_page - 1]), name)

    def render_file(path, name):
        save(Image.open(os.path.expanduser(path)), name)

    for key in keys:
        cfg = books[key]
        if cfg.get("static"):                     # hand-made book (e.g. the course)
            continue
        if cfg.get("cover_image"):                # a ready-made cover image file
            render_file(cfg["cover_image"], cfg["slug"])
        else:                                     # render from a PDF page
            render_pdf(cfg.get("cover_pdf", cfg["pdf"]), cfg["slug"], cfg.get("cover_page", 1))
        for extra in cfg.get("extra_covers", []):
            render_pdf(extra["pdf"], extra["name"], extra.get("cover_page", 1))

if __name__ == "__main__":
    main()
