#!/usr/bin/env raku

# rebase.raku — rewrite a built site (_out) to live under a URL sub-path.
#
# The pages use root-absolute links (/assets/…, /using-raku/…). To host the site
# at, say, andrewshitov.com/raku-books, every such link needs the prefix. This
# walks the built output and prefixes:
#
#   * HTML  — href="/…", src="/…", content="/…"   (skips external, protocol-
#             relative, anchors, and links already carrying the prefix)
#   * JSON  — the "u" URL field in search-index.json
#
# Assets resolve themselves at runtime: raku.js loads its WASM relative to its own
# <script src>, and search.js derives the base from the course.css link, so only
# these static links need touching.
#
# Usage:  raku tools/rebase.raku [_out] [/raku-books]

# Recursively list files under $dir, never descending into a symlink (the
# _out/assets symlink points back out of the tree).
sub walk(IO::Path $dir) {
    gather for $dir.dir -> $e {
        if $e.l         { next }          # skip symlinks (assets)
        elsif $e.d      { take $_ for walk($e) }
        elsif $e.f      { take $e }
    }
}

sub MAIN($out = '_out', $prefix is copy = '/raku-books') {
    $prefix .= subst(/ ^ '/'+ | '/'+ $ /, '', :g);   # strip leading/trailing slashes
    $prefix = '/' ~ $prefix;                          # normalise to one leading slash
    my $pfx-slash = $prefix.substr(1) ~ '/';          # e.g. "raku-books/"

    my ($n-html, $n-json) = 0, 0;
    for walk($out.IO) -> $f {
        if $f.extension eq 'html' {
            my $html = $f.slurp;
            my $new  = $html.subst(
                / $<a>=[ 'href' | 'src' | 'content' ] '="' '/'
                  <!before '/'> <!before $pfx-slash> /,
                { $<a> ~ '="' ~ $prefix ~ '/' }, :g);
            if $new ne $html { $f.spurt($new); $n-html++ }
        }
        elsif $f.basename eq 'search-index.json' {
            my $json = $f.slurp;
            my $new  = $json.subst(
                / '"u":"' '/' <!before $pfx-slash> /,
                '"u":"' ~ $prefix ~ '/', :g);
            if $new ne $json { $f.spurt($new); $n-json++ }
        }
    }
    say "rebased under $prefix: $n-html HTML file(s), $n-json search index";
}
