#!/usr/local/bin/raku

use YAMLish;

my %toc;
# How many parts to actually publish. Parts numbered above this are listed on
# the front page (greyed out) but not generated, and links into them are muted.
my $published-limit = Inf;

# When set (via --check-code), every runnable Raku block is passed through
# `raku -c` at build time; blocks that fail to compile get a `code-flagged`
# class so they stand out for review (see format-code).
my $check-code = False;

# The books site is English-only. The generator still iterates this list, so a
# single entry keeps all the per-language machinery working with no `en/` prefix.
my @languages =
    en => 'English';

enum PageType < Part Subpart Section Topic Exercise Exercises Solution Quiz >;
my %pagetype-key =
    Section => 'sections',
    Topic => 'topics',
    Exercise => 'exercises',
    Quiz => 'quizzes';


sub get-toc($lang, $is-silent) returns Hash {
    # URL levels:
    #  L1         L2               L3
    # /essentials/running-programs/from-ide/
    #  ^ part     ^ section        ^ topic
    #   | subpart is not part of URL

    my $prev-url = '';

    sub read-toc($lang) {
        my $yaml-content = "_data/toc/$lang.yaml".IO.slurp;
        my $content = load-yamls($yaml-content)[0];

        return $content;
    }

    sub scan-parts($toc, $is-silent = False) {        
        my $part-number = 0;

        for @$toc -> $part {
            my $part-title = $part<title>;
            my $part-url = $part<url>;

            # Only parts that hold content ('items') are numbered; intro pages
            # such as "About this course" are not counted.
            $part-number++ if $part<items>;

            say "Part $part-number. \e[1m$part-title\e[0m \e[34m$part-url\e[0m" unless $is-silent;

            %toc{$part-url} = {
                title => $part-title,
                long-title => $part<long_title>,
                description => $part<description>,
                url => $part-url,
                prev-url => $prev-url,
                type => Part,
                part-number => ($part<items> ?? $part-number !! Nil),
                items => $part<items>,
                pseudo => $part<pseudo>,
                covers => $part<covers>,
                meta => $part<meta>,
                gallery => $part<gallery>,
                banner => $part<banner>,
            };
            $prev-url = $part-url;

            scan-subparts($part<items>, $part-url, $is-silent) if $part<items>;
        }
    }

    sub scan-subparts($subparts, $parent-url, $is-silent = False) {
        for @$subparts -> $subpart {
            my $subpart-title = $subpart<title>;
            # A subpart with a `url` gets its own landing page at part/slug; one
            # without stays a plain header (the historical behaviour). Sections
            # keep their flat part/section URLs either way — the subpart page is
            # a sibling that groups them, not a new URL level.
            my $subpart-slug = $subpart<url>;
            my $subpart-url  = $subpart-slug ?? "$parent-url/$subpart-slug" !! Nil;

            say "    Subpart \e[1m$subpart-title\e[0m"
                ~ ($subpart-url ?? " \e[34m$subpart-url\e[0m" !! '') unless $is-silent;

            %toc{$parent-url}<subparts> //= [];
            @(%toc{$parent-url}<subparts>).push: {
                type  => Subpart,
                title => $subpart-title,
                url   => $subpart-url,
            };

            if $subpart-url {
                %toc{$subpart-url} = {
                    title       => $subpart-title,
                    long-title  => $subpart<long_title>,
                    description => $subpart<description>,
                    url         => $subpart-slug,
                    type        => Subpart,
                    prev-url    => $prev-url,
                    part-url    => $parent-url,
                    items       => $subpart<items>,   # raw sections, for render-subpart
                    sections    => [],                # section URLs, filled by scan-levels
                };
                $prev-url = $subpart-url;
            }

            scan-levels($subpart<items>, $parent-url, Section, $is-silent, $subpart-url) if $subpart<items>;
            scan-levels($subpart<exercises>, $parent-url, Exercise, $is-silent) if $subpart<exercises>;
            scan-levels($subpart<quizzes>, $parent-url, Quiz, $is-silent) if $subpart<quizzes>;
        }
    }

    sub scan-levels($levels, $parent-url, $type, $is-silent = False, $subpart-url = Nil) {
        for @$levels -> $level {
            my $level-title = $level<title>;
            my $level-url = $level<url>;

            my $url = $type == Exercise ?? "$parent-url/exercises/$level-url"
                                        !! "$parent-url/$level-url";

            %toc{$url} = {
                title => $level-title,
                url => $level-url,
                prev-url => $prev-url,
                type => $type,
            };
            # Record which subpart a section belongs to, so its breadcrumb can
            # show the grouping even though the subpart is not in the URL path.
            # Guard the push: if a subpart slug collides with a section slug the
            # section entry overwrites the subpart's, leaving <sections> unset —
            # skip rather than crash on an immutable value.
            if $type == Section && $subpart-url && $url ne $subpart-url {
                %toc{$url}<subpart-url> = $subpart-url;
                %toc{$subpart-url}<sections>.push($url)
                    if %toc{$subpart-url}<sections> ~~ Array;
            }
            $prev-url = $url;

            my $pagetype-key = %pagetype-key{$type};
            # %toc{$parent-url}{$pagetype-key} //= ();
            %toc{$parent-url}{$pagetype-key}.push($url);

            my $indent = "    " x $parent-url.comb('/').elems + 2;
            say "$indent $type \e[1m$level-title\e[0m \e[34m$url\e[0m" unless $is-silent;

            if $type eq Exercise {
                add-exercises-page($url);

                my $solution-url = "$url/solution";
                %toc{$solution-url} = {
                    title => "Solution: $level-title",
                    url => 'solution',
                    prev-url => $url,
                    type => Solution,
                };
                $prev-url = $solution-url;
            }

            scan-levels($level<items>, $url, Topic, $is-silent) if $level<items>;
            scan-levels($level<exercises>, $url, Exercise, $is-silent) if $level<exercises>;
            scan-levels($level<quizzes>, $url, Quiz, $is-silent) if $level<quizzes>;
        }

        sub add-exercises-page($url) {
            my $exercises-url = parent-level-url($url);
            my $parent-url = parent-level-url($exercises-url);

            %toc{$exercises-url} //= {
                title => "Exercises: %toc{$parent-url}<title>",
                short-title => 'Exercises',
                url => 'exercises',
                prev-url => $url,
                type => Exercises,
            };
        }
    }

    sub link-toc() {
        # Sorted, so that when two pages claim the same prev-url (a section's
        # first exercise is claimed by both its solution page and the
        # exercises index), the winner does not depend on hash order.
        for %toc.keys.sort -> $url {
            my $prev = %toc{$url}<prev-url>;
            %toc{$prev}<next-url> = $url if $prev;
        }
    }

    my $toc = read-toc($lang);    
    scan-parts($toc<toc>, $is-silent);

    link-toc();

    # The home page ('' / the site root). It is not a Part itself; it holds the
    # ordered list of parts so include-toc can render the whole-course TOC.
    %toc{''} = {
        title    => $toc<title>,
        url      => '',
        type     => Part,
        parts    => $toc<toc>,
        next-url => %toc{''}<next-url>,
    };

    return %toc;
}

sub generate-pages(%toc, $lang, $destination, $filter, $uri, $highlighter, $workers) {
    my $nw = (+$workers) max 1;   # number of parallel page-rendering workers (>= 1)
    # Resolve the requested highlighter to a runnable command (or nothing, e.g.
    # under --highlighter=none, or if the chosen tool isn't installed).
    my %hl = find-highlighter($highlighter);
    if %hl<exe> {
        say "\e[32m{%hl<name>} highlighter (%hl<exe>).\e[0m";
    }
    else {
        say "\e[31mNo working highlighter, code blocks will not be colour-highlighted.\e[0m";
    }

    my $which-pandoc = run 'which', 'pandoc', :out;
    my $pandoc-path = $which-pandoc.out.slurp.trim;
    unless $pandoc-path {
        say "No pandoc found.";
        exit;
    }
    say "Pandoc found at $pandoc-path";

    # Ensure the assets symlink exists — a fresh `rm -rf _out` removes it, which
    # would leave every page unstyled. Recreate it so builds are self-contained.
    $destination.IO.mkdir;

    # GitHub Pages: an empty .nojekyll disables Jekyll, so our already-final
    # HTML — and the many `_`-prefixed asset paths Jekyll would otherwise drop —
    # is served exactly as generated.
    "$destination/.nojekyll".IO.spurt('') unless "$destination/.nojekyll".IO.e;

    my $assets-link = "$destination/assets";
    unless $assets-link.IO.e {
        run 'ln', '-s', '../assets', $assets-link;
        say "\e[32mCreated $assets-link -> ../assets\e[0m";
    }

    # Related-documentation links: maps a section path (part/section) to a list
    # of {title, url} pages on docs.raku.org. Every content page under a section
    # shows them in a block at the bottom (see the {{ related-docs }} template
    # token). The map is optional — sections without an entry get no block.
    my %docs-links;
    my $docs-file = "_data/docs/$lang.yaml";
    %docs-links = load-yamls($docs-file.IO.slurp)[0] // %() if $docs-file.IO.f;

    sub related-docs(%content) {
        my @seg = (%content<url> // '').split('/').grep(*.chars);
        return '' unless @seg >= 2;
        # Theory pages only: skip quizzes, exercises, solutions, and listings.
        return '' if @seg.tail eq 'quiz' || @seg.any eq 'exercises';
        my $links = %docs-links{@seg[0, 1].join('/')};
        return '' unless $links;
        # Emit raw HTML (not Markdown) so the links can open in a new tab; the
        # external-link icon after each is added by CSS (div.related-docs a).
        my $items = $links.map({
            "<li><a href=\"https://docs.raku.org{.<url>}\" target=\"_blank\" rel=\"noopener noreferrer\">{html-escape(.<title>)}</a></li>"
        }).join("\n");
        return "<div class=\"related-docs\">\n"
            ~ "<p>📖 Related documentation on <a href=\"https://docs.raku.org\" target=\"_blank\" rel=\"noopener noreferrer\">docs.raku.org</a>:</p>\n"
            ~ "<ul>\n$items\n</ul>\n</div>";
    }

    my $saved-count   = 0;
    my $pending-count = 0;
    my @pending-pages;
    my @search-docs;   # {u, t, b} per page, written out as search-index.json

    # Reduce a page's Markdown to plain, searchable text. We deliberately KEEP
    # operator characters (* ~ | < > = : / # _ etc.) and code verbatim, so the
    # search can find operators like ** ~~ <=> Z= — only structural Markdown is
    # removed.
    sub index-text($md is copy) {
        $md ~~ s/ ^ '---' \n .*? \n '---' \n //;          # YAML frontmatter
        $md ~~ s:g/ '{%' .*? '%}' //;                     # {% include ... %}
        $md ~~ s:g/ '{:' <-[}]>* '}' //;                  # {:.quiz} etc.
        $md ~~ s:g/ '```' \N* \n //;                      # code-fence lines (keep the code)
        $md ~~ s:g/ '!'? '[' (<-[\]]>*) ']' '(' <-[)]>* ')' /$0/;  # [text](url) / ![alt](url) → text
        $md ~~ s:g/ '`' //;                               # inline-code backticks (keep content)
        $md ~~ s:g/ ^^ \h* '#'+ \h* //;                   # leading heading hashes
        $md ~~ s:g/ \s+ / /;                              # collapse whitespace
        return $md.trim;
    }

    # Plain-text version of a node title: strip Markdown code/emphasis markers,
    # link syntax, and the temporary 🆕 marker. Used for <title> tags and search
    # result labels, neither of which should show raw markup.
    sub clean-title($t is copy) {
        $t ~~ s:g/ '`' //;                                # inline-code backticks
        $t ~~ s:g/ <[*_]> //;                             # * _ emphasis
        $t ~~ s:g/ '[' (<-[\]]>*) ']' '(' <-[)]>* ')' /$0/;  # [text](url) → text
        $t ~~ s:g/ \s* '🆕' \s* //;                        # temporary new-marker
        $t ~~ s:g/ \s+ / /;
        return $t.trim;
    }

    sub json-escape($s) {
        # Replace every control character (Unicode category Cc — includes \n \t \r
        # and any stray control codes left by odd PDF font encodings) with a space,
        # then escape backslash and quote. Without the Cc pass a single control
        # byte in the page text produces invalid JSON and breaks the whole search.
        $s.subst(/<:Cc>/, ' ', :g).subst('\\', '\\\\', :g).subst('"', '\\"', :g);
    }

    sub build-search-json(@docs) {
        '[' ~ @docs.map({
            '{"u":"' ~ json-escape(.<u>) ~ '","t":"' ~ json-escape(.<t>)
            ~ '","b":"' ~ json-escape(.<b>) ~ '"}'
        }).join(',') ~ ']';
    }

    sub post-process-html($html) {
        return $html
            .subst('<p>%%tipblock</p>', '<div class="tip"><p></p>')
            .subst('<p>%%/tipblock</p>', '</div>');
    }

    # Render one page and return a result hash. Deliberately does NOT mutate the
    # shared counters or @search-docs — those are merged afterwards, in sorted order,
    # so the output (and search-index.json) is identical no matter how many workers
    # run. Only reads shared state (%toc, $destination, %hl, …) and writes its own file.
    sub render-page($dir) {
        # $dir is '' for the home page, so join carefully to avoid a leading '/'.
        my $src-dir = ($lang eq 'en' ?? $dir !! ($dir ?? "$lang/$dir" !! $lang));
        my $path = $src-dir ?? "$src-dir/index.md" !! 'index.md';
        my $title = %toc{$dir}<title>;

        # Subpart landing pages are synthesised — they need no hand-written file,
        # just the breadcrumb and a table of contents for their sections.
        my $is-subpart = %toc{$dir}<type> == Subpart;

        unless $path.IO.f || $is-subpart {
            say "\e[33mTODO: '$dir' — '$title' not yet written ($path)\e[0m";
            # Explicit pairs, not `:$dir` shorthand: rakupp loses a colon-pair
            # shorthand hash returned from inside a `start` block (comes back Nil).
            return { dir => $dir, title => $title, kind => 'pending' };
        }

        my $md = $path.IO.f
            ?? $path.IO.slurp
            !! '{% include menu.html %}' ~ "\n\n" ~ '{% include toc.html %}' ~ "\n";
        my $html = md-to-html(
            md => $md,
            title => $title,
            url => $dir,
            path => $path,
            lang => $lang,
            locale => $lang,
        );

        $html = post-process-html($html) if $html ~~ /'%%'/;
        $html = neutralize-unpublished-links($html) if $dir;

        # Every content page gets runnable code blocks via the raku.online embed
        # widget: it turns each highlighted Raku block into a play-and-edit editor.
        # `data-selector` targets `.highlight.raku` blocks that are NOT marked
        # `.no-run` — program output (```` ``` ```` console) is `.highlight` only,
        # and illustrative fragments are tagged `.no-run` by the extractor, so both
        # are left as static, coloured display. The widget and its ~4.7 MB WASM
        # engine are loaded straight from raku.online (raku.js resolves rakujs.js /
        # rakujs.wasm relative to its own <script src>), so the site itself carries
        # no WASM. The Run button picks up the accent colour from the
        # --rk-embed-accent variable set in course.css.
        if $dir {
            my $embed = '<script src="https://raku.online/raku.js"'
                      ~ ' data-selector=".highlight.raku:not(.no-run)" defer></script>';
            $html .= subst('</body>', "$embed\n</body>");
        }

        my $output-dir = $lang eq 'en' ?? "$destination/$dir" !! "$destination/$lang/$dir";
        try $output-dir.IO.mkdir(:parent);   # `try`: tolerate a peer worker creating a shared parent dir

        my $output-path = "$output-dir/index.html";
        $output-path.IO.spurt($html);
        say "\e[32mSaved to $output-path\e[0m";

        # Collect this page for the full-text search index (skip the home page —
        # its text is just the table of contents).
        my $search-doc = Nil;
        if $dir {
            my $text = index-text($md);
            $search-doc = {
                u => ($lang eq 'en' ?? "/$dir" !! "/$lang/$dir"),
                t => clean-title($title // ''),
                b => $text,
            } if $text;
        }
        # Explicit pairs, not `:$dir`/`:$search-doc` shorthand — see the pending
        # return above: rakupp drops a shorthand-pair hash returned from `start`.
        return { dir => $dir, kind => 'saved', search-doc => $search-doc };
    }

    # Sorted, so the search-index entry order (and everything merged below) is stable
    # from run to run — hash order isn't.
    my @dirs = %toc.keys.sort.grep({
        !($filter && $_ !~~ /$filter/) && !($uri && $_ ne $uri) && !beyond-limit($_)
    });

    # Render across $nw workers. The first page renders on its own so md-to-html's
    # `state` (template, includes) initialises single-threaded before any concurrent
    # access; the rest go out in batches of $nw. Real parallelism needs Rakudo:
    # run `raku raku-pages.raku …`, not `rakupp raku-pages.raku …`. rakupp does not
    # thread `start`/`await`, so under it a `--workers=N` build is just sequential
    # (same output, no speedup) — and the worker returns MUST use explicit pairs,
    # since rakupp drops a colon-pair-shorthand hash returned from a `start` block.
    my @results;
    if $nw > 1 && @dirs.elems > 1 {
        @results.push: render-page(@dirs[0]);
        my $i = 1;
        while $i < @dirs.elems {
            my $hi = min($i + $nw, @dirs.elems);
            @results.append: await @dirs[$i ..^ $hi].map(-> $d { start render-page($d) });
            $i = $hi;
        }
    }
    else {
        @results = @dirs.map({ render-page($_) });
    }

    # Merge results in sorted order → deterministic counters and search index.
    for @results -> $r {
        if $r<kind> eq 'saved' {
            $saved-count++;
            @search-docs.push($r<search-doc>) if $r<search-doc>;
        }
        else {
            $pending-count++;
            @pending-pages.push: "$r<dir> ($r<title>)";
        }
    }

    say "\e[1m\e[32m$saved-count page(s) generated for '$lang'.\e[0m"
        ~ ($pending-count ?? " \e[33m$pending-count page(s) still to write:\e[0m" !! '');
    say "  \e[33m• $_\e[0m" for @pending-pages.sort;

    # Write the full-text search index — but only for a complete build, so a
    # filtered/single-page run never clobbers the full index.
    unless $filter || $uri {
        my $index-path = $lang eq 'en'
            ?? "$destination/search-index.json"
            !! "$destination/$lang/search-index.json";
        $index-path.IO.spurt(build-search-json(@search-docs));
        say "\e[32mSearch index: {@search-docs.elems} pages → $index-path\e[0m";
    }

    sub md-to-html(*%content) {
        state $template = "_templates/default.html".IO.slurp;

        # A simple standard footer shown on every page, including the home page
        # (which keeps its own translations block above it).
        sub page-footer() {
            my $year = Date.today.year;
            return qq:to/FOOTER/;
            <footer class="site-footer" style="margin-top: 3rem; padding-top: 1.25rem; border-top: 1px solid rgba(128,128,128,.25); font-size: 85%; text-align: center; opacity: .75;">
            <p style="margin:.35em 0;"><a href="/">Andrew Shitov’s Raku Books</a></p>
            <p style="margin:.35em 0;"><a href="/tested-programs">Tested programs</a> · <a href="https://course.raku.org" target="_blank" rel="noopener noreferrer">Raku Course</a> · <a href="https://raku.org" target="_blank" rel="noopener noreferrer">Raku.org</a> · <a href="https://raku.online" target="_blank" rel="noopener noreferrer">Raku Playground</a> · <a href="https://github.com/ash/books" target="_blank" rel="noopener noreferrer">GitHub</a></p>
            <p style="margin:.35em 0;">Books written by <a href="https://andrewshitov.com/">Andrew Shitov</a> · Interactive edition © 2017–{$year}</p>
            </footer>
            FOOTER
        }

        sub field-substitute($from) {
            given $from {
                when 'title' {
                    # Home page gets the site name; every other page gets its
                    # cleaned title followed by the book/site name.
                    return 'Andrew Shitov’s Raku Books'
                        if (%content<url> // '') eq '';
                    return clean-title(%content<title> // '') ~ ' — Raku Books';
                }

                when / 'lang' | 'locale' /   { return %content{$from} }

                when 'content' { return prepare-content(%content<md>) }

                when 'head-includes' { return head-includes(%content) }

                when 'book-switcher' { return book-switcher(%content) }

                when 'footer' { return page-footer() }

                default {
                    say "\e[31mERROR: Unknown command '$from' in '%content<path>'\e[0m";
                    return '';
                }
            }
        }

        sub format-code($language is copy, $code, :$norun) {
            # Raku blocks carry an extra `raku` class on the wrapper so that the
            # copy-to-clipboard button (added by copy-code.js) attaches only to
            # them — never to program output (```console) or data (```json).
            # `:norun` adds a `no-run` class: the block is highlighted like any
            # other, but the play-editor script skips it (used for the illustrative
            # code fragments nested inside numbered comments — see prepare-content).
            # The extractor tags each Raku block by whether it earned a Run button
            # (see tools/verify.py):
            #   raku            → runnable            (Run button)
            #   raku-static     → fragment            (highlighted, no Run, no note)
            #   raku-nobrowser  → valid but Raku++ can't run it yet (no Run + a note)
            #   raku-local      → needs the local environment (files/CLI)  (no Run + a note)
            #   raku-async      → uses concurrency (promises/threads)      (no Run + a note)
            my $lang       = $language.lc;
            my $is-raku    = so $lang eq any('raku', 'perl6', 'raku-static', 'perl6-static',
                                             'raku-nobrowser', 'perl6-nobrowser',
                                             'raku-local', 'perl6-local',
                                             'raku-async', 'perl6-async');
            my $static     = $lang.ends-with('-static');
            my $nobrowser  = $lang.ends-with('-nobrowser');
            my $local      = $lang.ends-with('-local');
            my $async      = $lang.ends-with('-async');
            # All these suppress the Run button; :norun (nested fragments) too.
            my $no-run     = $norun || $static || $nobrowser || $local || $async;
            # Normalise the language handed to the highlighter to plain 'raku'.
            $language = $is-raku ?? 'raku' !! $language;
            # Run & flag: when --check-code is on, compile each *runnable* block with
            # `raku -c` and mark failures with a `code-flagged` class for review.
            my $flagged = $check-code && $is-raku && !$no-run && !raku-compiles($code);
            my $raku-class = ('highlight', 'raku',
                              ($no-run  ?? 'no-run'      !! Empty),
                              ($flagged ?? 'code-flagged' !! Empty)).join(' ');
            my $wrapper = $is-raku ?? $raku-class !! 'highlight';
            # A no-run block that a reader might expect to run gets an explanatory note.
            my $note =
                $async     ?? qq[\n<p class="run-note">🧵 This program uses concurrency (promises, threads). The in-browser engine (Raku.js) is single-threaded and can’t run it yet — try it on your own computer.</p>]
              !! $nobrowser ?? qq[\n<p class="run-note">↻ Runs in Rakudo; the in-browser engine (Raku++) doesn’t support this program yet — see the expected output above.</p>]
              !! $local    ?? qq[\n<p class="run-note">🖥 This program reads the local environment (files, directories, or the command line), so it runs on your own computer but not in the sandboxed in-browser engine.</p>]
              !! '';

            # Plain, HTML-escaped code block — matching the wrapper pygments uses
            # — so the code is always marked up and styled even without a
            # highlighter (--highlighter=none, no pygments, or a per-block failure).
            my $plain = qq[<div class="$wrapper"><pre>] ~ html-escape($code) ~ '</pre></div>';

            return $plain ~ $note unless %hl<exe>;

            # Only Raku code is syntax-highlighted. Everything else — program
            # output (whether bare or marked ```console), JSON, etc. — stays
            # plain, so it is never coloured as if it were Raku code.
            return $plain ~ $note unless $is-raku;

            # Pipe the code through the highlighter via stdin/stdout. (Using a shared
            # temp file here races: an async read can pick up another block's output.)
            # Both pygmentize and `rakupp --highlight` read stdin and emit the same
            # class-based <div class="highlight"> HTML — tokens get short CSS classes
            # (.k, .s, …) coloured by course.css, so both palettes theme from the
            # stylesheet. Only pygments needs the -l language flag.
            my $proc = %hl<name> eq 'rakupp'
                ?? run(%hl<exe>, '--highlight', '--html', :in, :out, :err)
                !! run(%hl<exe>, '-f', 'html', '-l', $language, :in, :out, :err);
            $proc.in.spurt($code, :close);
            my $html = $proc.out.slurp(:close);
            $proc.err.slurp(:close);

            return $plain ~ $note unless $proc.exitcode == 0 && $html.trim;

            # The highlighter emits <div class="highlight">; add the `raku` marker
            # class so the copy button hooks onto highlighted blocks too.
            return $html.subst('<div class="highlight">', qq[<div class="$raku-class">]) ~ $note;
        }

        sub format-quiz($class is copy, $body) {
            my $rows;
            for $body.split("\n") -> $row {
                $rows ~= '<tr>';
                for $row.split(/\s* '|' \s*/) -> $cell is copy {
                    # Render inline `code` spans in cells, as kramdown did.
                    $cell ~~ s:g/ '`' $<c>=(<-[`]>*) '`'
                        /{ '<code>' ~ html-escape(~$<c>) ~ '</code>' }/;
                    $rows ~= "<td>{$cell}</td>";
                }
                $rows ~= "</tr>\n";
            }

            $class ~~ s:g/'.'//;

            return qq:to/QUIZ/;
            <table class="$class">
            $rows
            </table>
            QUIZ
        }

        sub include-stats() {
            # Shelf-size figures for the home page, counted live from the TOC so
            # they never go stale: books (top-level parts with content), chapters
            # (their subparts), and total content pages that have a real index.md.
            my @v = %toc.values;
            my $books    = @v.grep({ .<type> == Part && .<items> }).elems;
            my $chapters = @v.grep({ .<type> == Subpart }).elems;

            # Topics — the content pages a reader reads (sections and topics),
            # excluding the home page, the register, and navigation landings.
            my $topics = @v.grep({ .<type> == Section | Topic }).elems;

            sub stat($n, $label) {
                # {$n}/{$label} braces stop Raku reading `$n<...>` as a subscript.
                qq[  <div class="stat"><span class="num">{$n}</span><span class="label">{$label}</span></div>];
            }

            return join "\n",
                '<div class="home-stats">',
                stat($books, $books == 1 ?? 'book' !! 'books'),
                stat($chapters, 'chapters'),
                stat($topics, 'topics'),
                '</div>';
        }

        sub process-includes($filename) {
            state %includes =
                'languages.html' => sub { '' },
                'nav.html' => &include-nav,
                'toc.html' => &include-toc,
                'menu.html' => &include-menu,
                'quiz.html' => &include-quiz,
                'stats.html' => &include-stats,
                'translations.html' => &include-translations,
            ;

            return %includes{$filename} ?? %includes{$filename}() !! '';
        }

        sub head-includes(%content) {
            if %toc{%content<url>}<type> == Quiz {
                return qq:to/INCLUDE/;
                <link rel="stylesheet" href="/assets/quiz.css?v=5">
                <script type="text/javascript" src="/assets/quiz.js?v=2"></script>
                INCLUDE
            }

            return '';
        }

        # The book-switcher dropdown shown in the top controls on every page. It
        # lists every book (top-level TOC part with content) and links to each
        # book's landing page; the current book (first URL segment) is preselected.
        # Navigation is done with a tiny inline onchange handler so no extra JS
        # file is needed.
        sub book-switcher(%content) {
            my @books = @(%toc{''}<parts> // []).grep({ .<items> || .<covers> });
            return '' unless @books;

            my $current = (%content<url> // '').split('/')[0] // '';
            my $opts = '';
            for @books -> $b {
                my $sel = $b<url> eq $current ?? ' selected' !! '';
                $opts ~= qq[<option value="/{$b<url>}"$sel>{html-escape(clean-title($b<title>))}</option>\n];
            }

            return qq:to/SWITCHER/;
            <div class="book-switch">
            <label class="book-switch-label" for="book-select">📚</label>
            <select id="book-select" class="book-select" aria-label="Switch book" onchange="if(this.value)location.href=this.value;">
            <option value="">Jump to a book…</option>
            {$opts}</select>
            </div>
            SWITCHER
        }

        sub include-menu() {
            my @crumbs = "[Raku Books](/)";

            my $full-url = %content<url>;
            my @seg = $full-url.split('/');
            # Ancestors are every path segment except the page's own (last) slug.
            my @ancestors = @seg[0 ..^ (@seg.elems - 1)];

            my $crumb-url = '';
            for @ancestors.kv -> $i, $current-url-part {
                $crumb-url = $crumb-url ?? "$crumb-url/$current-url-part" !! $current-url-part;

                my $toc-item = %toc{$crumb-url};
                my $title = $toc-item<short-title> // $toc-item<title>;
                @crumbs.push: "[$title](/$crumb-url)";

                # Right after the part crumb, insert the subpart this page's
                # section belongs to — it groups the sections but is not itself
                # a segment of their (flat) URL.
                if $i == 0 && @seg.elems >= 2 {
                    my $section-url = @seg[0, 1].join('/');
                    my $subpart-url = %toc{$section-url}<subpart-url>;
                    if $subpart-url {
                        my $sp = %toc{$subpart-url};
                        @crumbs.push: "[{$sp<short-title> // $sp<title>}](/$subpart-url)";
                    }
                }
            }

            # Part-landing pages take their heading from toc.html (render-part,
            # which shows "Part N. …"), so suppress the duplicate title here.
            my $title-md = %toc{$full-url}<part-number> ?? '' !! "\n\n# {%content<title>}";
            return "{@crumbs.join(' / ')}$title-md\n";
        }

        sub include-quiz() {
            # NB: keep every line flush-left. Markdown turns indented lines into
            # a code block, which would print the button tags as text.
            return qq:to/QUIZ/;
            <script>
            prepare_quiz();
            </script>
            <div class="quiz-actions" style="margin: 3em 0;">
            <button class="quiz-btn quiz-btn-primary" onclick="checkquiz()">Check the answers</button>
            <button class="quiz-btn quiz-btn-ghost" onclick="showanswers()" id="ShowAnswers" style="display: none;">Show correct answers</button>
            </div>
            QUIZ
        }

        sub include-nav() {
            my $url = %content<url>;

            sub topics-list() {
                my $curr = %toc{$url};
                return '' unless $curr<topics>;

                my @topics = @($curr<topics>);

                my $lang-prefix = %content<lang> eq 'en' ?? '' !! "/%content<lang>";
                my $topics;
                for @topics -> $topic-url {
                    my $topic = %toc{$topic-url};
                    $topics ~= "* [$topic<title>]($lang-prefix/$topic-url)\n";
                }

                return qq:to/TOPICS/;
                <div class="topics" markdown="1">
                ## {@topics.elems > 1 ?? "Topics in this section" !! "Also in this section"}
                $topics
                </div>
                TOPICS
            }

            sub quizzes-list() {
                my $curr = %toc{$url};

                # A topic page lists its own quizzes. A section landing page has
                # none of its own, so it aggregates the quizzes of its topics —
                # giving the section one place that gathers all its practice.
                my @quizzes = @($curr<quizzes> // []);
                for @($curr<topics> // []) -> $topic-url {
                    @quizzes.append: @(%toc{$topic-url}<quizzes> // []);
                }

                return '' unless @quizzes;

                my $lang-prefix = %content<lang> eq 'en' ?? '' !! "/%content<lang>";
                my $quizzes;
                for @quizzes -> $quiz-url {
                    my $quiz = %toc{$quiz-url};
                    $quizzes ~= "* [$quiz<title>]($lang-prefix/$quiz-url)\n";
                }

                my $scope = $curr<topics> ?? 'section' !! 'topic';
                return qq:to/QUIZZES/;
                <div class="practice" markdown="1">
                ## Practice

                Complete the quiz{@quizzes.elems > 1 ?? 'zes' !! ''} that cover{@quizzes.elems == 1 ?? 's' !! ''} the contents of this $scope.

                $quizzes
                </div>
                QUIZZES
            }

            sub exercises-list() {
                my $curr = %toc{$url};

                my $parent-url = $url;
                if $curr<type> == Exercises {
                    $parent-url ~~ s/ '/exercises' $ //;
                    $curr = %toc{$parent-url};
                }

                return '' unless $curr<exercises>;

                my @exercises = @($curr<exercises>);

                my $lang-prefix = %content<lang> eq 'en' ?? '' !! "/%content<lang>";
                my $exercises;
                for @exercises -> $exercise-url {
                    my $exercise = %toc{$exercise-url};
                    $exercises ~= "1. [$exercise<title>]($lang-prefix/$exercise-url)\n";
                }

                if $url ne $parent-url {
                    my $parent = %toc{$parent-url};
                    my $local-toc = '';
                    for @($parent<topics> // []) -> $topic-url {
                        my $topic = %toc{$topic-url};
                        $local-toc ~= qq:to/LOCAL-TOC/;
                            * [$topic<title>](/$parent-url/$topic<url>)
                        LOCAL-TOC
                    }

                    return qq:to/EXERCISES/;
                    <div class="exercises" markdown="1">
                    <p></p>

                    This section contains {decline(@exercises.elems, 'exercise')}.

                    $exercises
                    </div>

                    ## Refresh your knowledge

                    Refer to the contents of this section to find the answers if needed.

                    * [$parent<title>](/$parent-url)
                    $local-toc

                    EXERCISES
                }
                else {
                    return qq:to/EXERCISES/;
                    <div class="exercises" markdown="1">
                    ## Exercises

                    This section contains [{decline(@exercises.elems, 'exercise')}](exercises). Examine all the topics of this section before doing the coding practice.

                    $exercises
                    </div>
                    EXERCISES
                }
            }

            my $prev-url  = %toc{$url}<prev-url>;
            my $next-url  = %toc{$url}<next-url>;
            my $prev-page = $prev-url ?? %toc{$prev-url} !! Nil;
            # Do not offer a "next" link that would jump into an unpublished part.
            my $next-page = ($next-url && !beyond-limit($next-url)) ?? %toc{$next-url} !! Nil;

            my $course-nav = '';
            $course-nav ~= "← [$prev-page<title>](/$prev-url)" if $prev-page;
            $course-nav ~= "\n&nbsp;&nbsp;|&nbsp;&nbsp;\n"      if $prev-page && $next-page;
            $course-nav ~= "[$next-page<title>](/$next-url) →" if $next-page;

            return qq:to/NAV/;
            {topics-list()}

            {quizzes-list()}

            {exercises-list()}

            ## Course navigation

            {$course-nav}

            {related-docs(%content)}

            {link-exercises-if-any()}

            {include-translations()}
            NAV
        }

        sub include-toc() {
            my $top = %content<lang> eq 'en' ?? '' !! "/%content<lang>";

            # A book's cover image(s). `covers` is a list of slugs (the book's own
            # plus any extra covers, e.g. an earlier edition); each that has a
            # rendered assets/covers/<slug>.jpg is shown. Returns '' if none, so a
            # book with no cover simply renders without one.
            sub book-cover-names($covers) {
                @($covers // []).grep({ "assets/covers/{$_}.jpg".IO.e });
            }
            sub book-covers-html($covers, $title, :$link) {
                my @names = book-cover-names($covers);
                return '' unless @names;
                my $multi = @names.elems > 1 ?? ' multi' !! '';
                my $imgs = @names.map({
                    qq[<img class="book-cover" src="/assets/covers/{$_}.jpg"]
                    ~ qq[ alt="{html-escape(clean-title($title))} cover" loading="lazy">]
                }).join('');
                my $div = qq[<div class="book-covers$multi">{$imgs}</div>];
                return $link ?? qq[<a class="book-cover-link" href="$link">{$div}</a>] !! $div;
            }

            # Bibliographic metadata for a book's landing page (author, publication
            # date + publisher, ISBN, page count), plus an optional note. Returns
            # '' when the book has no `meta` entry.
            sub book-meta-html($meta) {
                return '' unless $meta;
                my @rows;
                @rows.push: ['Author', ~$meta<author>]  if $meta<author>;
                my $pub = ($meta<published>, $meta<publisher>).grep(*.defined).join(' · ');
                @rows.push: ['Published', $pub]          if $pub;
                @rows.push: ['ISBN', ~$meta<isbn>]       if $meta<isbn>;
                @rows.push: ['Pages', ~$meta<pages>]     if $meta<pages>;
                return '' unless @rows;
                # <dl>/<dt>/<dd> stays block-level through pandoc (so the grid keeps
                # its two columns); the CSS resets the markdown-body dt/dd defaults.
                my $items = @rows.map({
                    qq[<div><dt>{html-escape(.[0])}</dt><dd>{html-escape(.[1])}</dd></div>]
                }).join("\n");
                my $note = $meta<note>
                    ?? qq[\n<p class="book-meta-note">{html-escape(~$meta<note>)}</p>] !! '';
                return qq[<dl class="book-meta">\n{$items}\n</dl>{$note}];
            }

            # On a part-landing page each section shows its quiz/exercise counts
            # ($extended); on the home page the whole-course TOC omits them.
            sub counts($node, $base) {
                my @parts;
                @parts.push: "<span class=\"has-q\">[{decline($node<quizzes>.elems, 'quiz')}]($base#practice)</span>"
                    if $node<quizzes>;
                @parts.push: "<span class=\"has-e\">[{decline($node<exercises>.elems, 'exercise')}]($base/exercises)</span>"
                    if $node<exercises>;
                return @parts ?? ' — ' ~ @parts.join(' and ') !! '';
            }

            sub render-part($part, Bool $extended, Bool :$heading = True) {
                my $part-url = $part<url>;
                my $long     = $part<long-title> // $part<title>;
                # A book-landing page is headed by the book's own title (no "Part N.").
                # When a cover image exists, show the title and blurb beside it.
                my $covers-html = book-covers-html($part<covers>, $part<title>);
                my $toc = '';
                if $heading && $covers-html {
                    $toc ~= "<div class=\"book-hero\">\n\n";
                    $toc ~= "$covers-html\n\n";
                    $toc ~= "<div class=\"book-hero-text\" markdown=\"1\">\n\n# $long\n\n";
                    $toc ~= "{$part<description>}\n\n" if $part<description>;
                    my $meta-html = book-meta-html($part<meta>);
                    $toc ~= "\n$meta-html\n\n" if $meta-html;
                    $toc ~= "</div>\n\n</div>\n\n";
                }
                else {
                    $toc ~= "# $long\n\n" if $heading;
                    # The part's own intro, above its table of contents (the same
                    # description shown on the home-page card).
                    $toc ~= "{$part<description>}\n\n" if $heading && $part<description>;
                }

                # An optional banner (e.g. an unpublished book still in proofreading).
                $toc ~= qq[<p class="book-banner">📝 {html-escape($part<banner>)}</p>\n\n]
                    if $heading && $part<banner>;

                # A gallery book (the Calendar) shows a grid of section thumbnails
                # instead of a text table of contents.
                if $part<gallery> {
                    # Emit the whole grid on ONE line so pandoc keeps it as a single
                    # raw HTML block. Any newline inside would make pandoc re-parse
                    # the inline <a> cells as a paragraph and wrap them in a <p>,
                    # which would collapse the grid to a single column.
                    my $cells = '';
                    for @($part<items> // []) -> $subpart {
                        for @($subpart<items> // []) -> $section {
                            my $surl  = "$top/$part-url/{$section<url>}";
                            my $thumb = $section<thumb>;
                            $cells ~= "<a class=\"gallery-cell\" href=\"$surl\">";
                            $cells ~= "<img src=\"{$thumb}\" alt=\"{html-escape($section<title>)}\" loading=\"lazy\">"
                                if $thumb;
                            $cells ~= "<span>{html-escape($section<title>)}</span></a>";
                        }
                    }
                    return $toc ~ "\n<div class=\"gallery-grid\">{$cells}</div>\n";
                }

                for @($part<items> // []) -> $subpart {
                    # A subpart with its own page becomes a link to that page.
                    $toc ~= $subpart<url>
                        ?? "#### [$subpart<title>]($top/$part-url/{$subpart<url>})\n\n"
                        !! "#### $subpart<title>\n\n";

                    for @($subpart<items> // []) -> $section {
                        my $surl = "$top/$part-url/$section<url>";
                        $toc ~= "* [$section<title>]($surl)"
                            ~ ($extended ?? counts($section, $surl) !! '') ~ "\n";

                        for @($section<items> // []) -> $topic {
                            my $turl = "$surl/$topic<url>";
                            my $tq = ($extended && $topic<quizzes>)
                                ?? " — <span class=\"has-q\">[{decline($topic<quizzes>.elems, 'quiz')}]($turl#practice)</span>"
                                !! '';
                            $toc ~= "    - [$topic<title>]($turl)$tq\n";
                        }
                    }

                    $toc ~= "\n";
                }

                return $toc;
            }

            my $url = %content<url>;

            # Home page: one card per part. The level-2 subparts are always
            # visible; only their sections/topics collapse (a <details> each).
            # An "expand all" button on the part header opens/closes every
            # subpart in the card at once.
            if $url eq '' {
                my @content-parts = @(%toc{''}<parts> // []).grep({ .<items> || .<pseudo> || .<covers> });
                my $expand-ico = '<svg viewBox="0 0 16 16" width="15" height="15" aria-hidden="true">'
                    ~ '<path d="M5 6.5 8 3.5l3 3" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>'
                    ~ '<path d="M5 9.5 8 12.5l3-3" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';

                my $toc = "<div class=\"course-map\">\n\n";
                for @content-parts -> $raw-part {
                    my $part = %toc{$raw-part<url>};
                    my $long = $part<long-title> // $part<title>;
                    my $href = "$top/{$part<url>}";

                    # A pseudo-part (e.g. the Final Test) gets a standout card
                    # with no number badge and no expandable section list.
                    if $part<pseudo> {
                        $toc ~= "<div class=\"part-card part-pseudo\">\n\n";
                        $toc ~= "<h3 class=\"part-head\"><span class=\"pnum pnum-star\">★</span>"
                            ~ " <a class=\"part-title\" href=\"{$href}\">{$long}</a></h3>\n\n";
                        $toc ~= "{$part<description>}\n\n" if $part<description>;
                        $toc ~= "</div>\n\n";
                        next;
                    }

                    # A standalone book with no chapters (e.g. the course
                    # placeholder that links out) gets a plain cover + blurb card,
                    # with no expand button or section list.
                    unless $part<items> {
                        my $ch = book-covers-html($part<covers>, $part<title>, link => $href);
                        $toc ~= "<div class=\"part-card{ $ch ?? ' has-cover' !! '' }\">\n\n";
                        $toc ~= "$ch\n\n" if $ch;
                        $toc ~= "<div class=\"part-body\">\n\n";
                        $toc ~= "<h3 class=\"part-head\"><a class=\"part-title\" href=\"{$href}\">{$long}</a></h3>\n\n";
                        $toc ~= "{$part<description>}\n\n" if $part<description>;
                        # An external link-list (e.g. the course's five parts) is
                        # shown like a book's chapter list.
                        if $raw-part<link-list> {
                            $toc ~= "<div class=\"subparts link-list\">\n\n";
                            for @($raw-part<link-list>) -> $item {
                                $toc ~= "* [{$item<title>}]({$item<url>})\n";
                            }
                            $toc ~= "\n</div>\n\n";
                        }
                        $toc ~= "</div>\n\n</div>\n\n";
                        next;
                    }

                    my $locked = ($part<part-number> // 0) > $published-limit;
                    my $covers-html = book-covers-html($part<covers>, $part<title>, link => $href);
                    $toc ~= "<div class=\"part-card{ $locked ?? ' part-locked' !! '' }{ $covers-html ?? ' has-cover' !! '' }\">\n\n";
                    $toc ~= "$covers-html\n\n" if $covers-html;
                    $toc ~= "<div class=\"part-body\">\n\n";
                    # No number badge — the books are a shelf, not a ranked series.
                    $toc ~= "<h3 class=\"part-head\">"
                        ~ "<a class=\"part-title\" href=\"{$href}\">{$long}</a>"
                        ~ ( $locked ?? " <span class=\"part-soon\">coming soon</span>" !! '' )
                        ~ " <button class=\"part-expand\" type=\"button\" aria-expanded=\"false\""
                        ~ " title=\"Expand all sections\" aria-label=\"Expand all sections\">{$expand-ico}</button></h3>\n\n";
                    $toc ~= "{$part<description>}\n\n" if $part<description>;

                    $toc ~= "<div class=\"subparts\">\n\n";
                    for @($part<items> // []) -> $subpart {
                        $toc ~= "<details class=\"toc-subpart\">\n";
                        my $sp-label = $subpart<url>
                            ?? "<a href=\"$top/{$part<url>}/{$subpart<url>}\">{$subpart<title>}</a>"
                            !! $subpart<title>;
                        $toc ~= "<summary>{$sp-label}</summary>\n\n";
                        for @($subpart<items> // []) -> $section {
                            my $surl = "$top/{$part<url>}/{$section<url>}";
                            $toc ~= "* [{$section<title>}]({$surl})\n";
                            for @($section<items> // []) -> $topic {
                                $toc ~= "    - [{$topic<title>}]({$surl}/{$topic<url>})\n";
                            }
                        }
                        $toc ~= "\n</details>\n\n";
                    }
                    $toc ~= "</div>\n\n";      # .subparts
                    $toc ~= "</div>\n\n";      # .part-body
                    $toc ~= "</div>\n\n";      # .part-card
                }
                $toc ~= "</div>\n\n";

                return $toc;
            }

            # Subpart landing page: just this subpart's sections, with counts.
            if %toc{$url}<type> == Subpart {
                return render-subpart(%toc{$url});
            }

            # Part-landing page: just this part, with quiz/exercise counts.
            return render-part(%toc{$url}, True);

            sub render-subpart($subpart) {
                my $part-url = $subpart<part-url>;
                my $toc = '';
                $toc ~= "{$subpart<description>}\n\n" if $subpart<description>;

                for @($subpart<items> // []) -> $section {
                    my $surl = "$top/$part-url/$section<url>";
                    $toc ~= "* [$section<title>]($surl)" ~ counts($section, $surl) ~ "\n";

                    for @($section<items> // []) -> $topic {
                        my $turl = "$surl/$topic<url>";
                        my $tq = $topic<quizzes>
                            ?? " — <span class=\"has-q\">[{decline($topic<quizzes>.elems, 'quiz')}]($turl#practice)</span>"
                            !! '';
                        $toc ~= "    - [$topic<title>]($turl)$tq\n";
                    }
                }

                return $toc;
            }
        }

        sub include-translations() {
            # The books site is English-only, so there is never a translations block.
            return '';
        }

        sub link-exercises-if-any() {
            my $url = %content<url>;
            my $curr = %toc{$url};

            return '' unless $curr<type> == Topic;

            my $section-url = parent-level-url($url);
            my $section = %toc{$section-url};

            return '' unless $section<exercises>;

            if $section<exercises>.elems == 1 {
                return qq:to/GOTOEXERCICE/;

                <br />
                💪 Or jump directly [to the exercise to this section](/$section<exercises>[0]).

                GOTOEXERCICE
            }
            else {
                return qq:to/GOTOEXERCICES/;

                <br />
                💪 Or jump directly [to the exercises in this section](/$section-url/exercises).

                GOTOEXERCICES
            }
        }

        sub prepare-content($md is copy) {
            $md ~~ s/ '---'\n .*? '---'\n //;
            $md ~~ s:g/ '{%' \s* 'include' \s+ (\S+) \s* '%}' /{ process-includes($0.trim) }/;
            # Resolve the only Liquid output tag still used in content: the
            # copyright year ({{ site.time | date: '%Y' }} on the home page).
            $md ~~ s:g/ '{{' \s* 'site.time' .*? '}}' /{ Date.today.year }/;
            # Drop any remaining Liquid tags ({% assign %}, {% comment %}, …) — the
            # Raku generator does its own logic, so these would otherwise leak as text.
            $md ~~ s:g/ '{%' .*? '%}' //;

            my @code = extract-code($md);
            my @quiz = extract-quiz($md);

            my $html = markdown2html($md);
            $html = rehighlight-fragments($html);

            $html ~~ s:g/ '<p>' 'CodeBlockPlaceholder' (\d+) '</p>'/@code[$0 - 1]/;
            $html ~~ s:g/ '<p>' 'QuizPlaceholder' (\d+) '</p>'/@quiz[$0 - 1]/;

            return $html;
        }

        sub markdown2html($md) {
            # Disable pandoc's $…$ TeX-math extension: Raku code and prose are
            # full of $variables, which must stay literal (kramdown did the same).
            # `--no-highlight`: pandoc must NOT syntax-colour code (its only targets
            # are blocks indented under list items, which our fence regex leaves for
            # it). It emits them as plain `<pre class="lang"><code>…</code></pre>`,
            # and rehighlight-fragments() below re-runs them through the course's own
            # `--highlighter`, so every block is coloured by one highlighter/palette.
            my $run = run $pandoc-path, '-f', 'markdown-tex_math_dollars',
                          '--no-highlight', :in, :out;
            $run.in.print($md);
            $run.in.close;

            return $run.out.slurp;
        }

        # Code blocks nested inside numbered comments are indented, so the fence
        # regex in extract-code() (which needs a column-0 closing ```) skips them
        # and pandoc renders them — as `<pre class="raku"><code>…</code></pre>` with
        # `--no-highlight`. Re-highlight each through format-code so it uses the same
        # highlighter and pygments classes as every other block; mark it `:norun`
        # (an illustrative fragment, not a program to run).
        sub rehighlight-fragments($html is copy) {
            # (.*?) for the class name, not a <-["]> character class: rakupp
            # cannot yet parse a `"` inside a char class within a sub body.
            $html ~~ s:g/ '<pre class="' (.*?) '"><code>' (.*?) '</code></pre>' /{
                format-code(~$0, html-unescape(~$1), :norun)
            }/;
            return $html;
        }

        sub extract-code($md is rw) {
            my @code;

            $md ~~ s:g/ '```' (\S+)? \n+ (.*?) \n+ '```' /{
                @code.push([($0 // '').Str, ~$1]);
                'CodeBlockPlaceholder' ~ @code.elems
            }/;

            return @code.map({
                format-code($_[0], $_[1])
            });
        }

        sub extract-quiz($md is rw) {
            my @quiz;

            $md ~~ s:g/ '{:' ('.quiz' .*?) '}' \n (.*?) \n\n /{
                @quiz.push([~$0, ~$1]);
                'QuizPlaceholder' ~ @quiz.elems
                ~ "\n\n"
            }/;

            return @quiz.map({
                format-quiz($_[0], $_[1])
            });
        }

        my $html = $template;
        $html ~~ s:g/ '{{' (.*?) '}}' /{ field-substitute($0.trim) }/;

        return $html;
    }

}

#| Locate a pygmentize that actually runs. `which` may return a broken script
#| (e.g. a wrong shebang), so each candidate is verified with `-V`.
sub find-pygmentize() {
    my @candidates;

    my $which = run 'which', '-a', 'pygmentize', :out, :err;
    @candidates.append: $which.out.slurp.lines».trim.grep(*.chars);

    @candidates.append: </opt/local/bin/pygmentize
                         /opt/homebrew/bin/pygmentize
                         /usr/local/bin/pygmentize>;

    my $frameworks = '/Library/Frameworks/Python.framework/Versions'.IO;
    @candidates.append: $frameworks.dir.map(*.add('bin/pygmentize').Str) if $frameworks.d;

    for @candidates.unique -> $path {
        next unless $path.IO.f;
        my $test = run $path, '-V', :out, :err;
        return $path if $test.exitcode == 0;
    }

    return '';
}

#| Locate a `rakupp` that supports `--highlight`. Assume `rakupp` is on PATH; an
#| optional $RAKUPP env var overrides it. Verify it actually highlights (older
#| builds may lack --highlight), so a missing/old rakupp falls back gracefully.
sub find-rakupp() {
    my @candidates = 'rakupp';
    @candidates.unshift: %*ENV<RAKUPP> if %*ENV<RAKUPP>;

    for @candidates -> $path {
        my $ok = try {
            my $test = run $path, '--highlight', :in, :out, :err;
            $test.in.spurt("1\n", :close);
            my $out = $test.out.slurp(:close);
            $test.err.slurp(:close);
            $test.exitcode == 0 && $out.contains('class="highlight"');
        };
        return $path if $ok;
    }

    return '';
}

#| Resolve the chosen highlighter to a runnable spec. $choice is one of
#| 'pygments', 'rakupp', 'auto' (prefer pygments, fall back to rakupp) or 'none'.
#| Returns a Hash with <name exe>, or an empty Hash if none found.
sub find-highlighter($choice) {
    my $c = $choice.lc;
    my @order;
    if $c eq 'none' {
        @order = ();
    }
    elsif $c eq 'rakupp' {
        @order = <rakupp>;
    }
    elsif $c eq 'pygments' {
        @order = <pygments>;
    }
    else {                                       # 'auto' (and any unknown value)
        @order = <pygments rakupp>;
    }

    for @order -> $which {
        if $which eq 'pygments' {
            my $p = find-pygmentize();
            return %( name => 'pygments', exe => $p ) if $p;
        }
        else {
            my $p = find-rakupp();
            return %( name => 'rakupp', exe => $p ) if $p;
        }
    }

    return %();
}

#| True if the given Raku source compiles (`raku -c`, syntax check only — it
#| never runs the program, so `prompt`, infinite loops, and network calls are
#| safe). Used by --check-code to flag blocks that don't compile. A block that
#| genuinely needs earlier context (a fragment) will fail here — that's why only
#| blocks NOT marked `:norun` are checked.
sub raku-compiles($code) {
    my $proc = run 'raku', '-c', '-e', $code, :out, :err;
    $proc.out.slurp(:close);
    $proc.err.slurp(:close);
    return $proc.exitcode == 0;
}

#| Escape the three characters that matter in HTML text/code.
sub html-escape($s) {
    return $s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g);
}

#| Reverse html-escape (plus the quote entities pandoc emits), so code pandoc
#| rendered as escaped text can be re-fed to the highlighter. `&amp;` last.
sub html-unescape($s) {
    return $s.subst('&lt;', '<', :g).subst('&gt;', '>', :g)
             .subst('&quot;', '"', :g).subst('&#39;', "'", :g)
             .subst('&amp;', '&', :g);
}

#| "1 exercise", "2 exercises", "1 quiz", "2 quizzes" — pick singular/plural.
sub decline($n, $word) {
    my %forms = quiz => <quiz quizzes>, exercise => <exercise exercises>;
    return "$n " ~ %forms{$word}[$n == 1 ?? 0 !! 1];
}

sub parent-level-url($url is copy) {
    $url ~~ s/ '/' <-[/]>+ $ //;
    return $url;
}

# The 1-based part number a URL belongs to (0 for the home page, about page,
# and anything not inside a numbered part).
sub part-number-of($url) {
    return 0 unless $url;
    return %toc{ $url.split('/')[0] }<part-number> // 0;
}

# True when a URL sits in a part beyond what we publish.
sub beyond-limit($url) {
    my $n = part-number-of($url);
    return $n && $n > $published-limit;
}

# Rewrite in-text links that point into an unpublished part into muted,
# non-clickable spans, so a published build never links to a missing page.
sub neutralize-unpublished-links($html) {
    return $html if $published-limit == Inf;
    my @locked = (%toc{''}<parts> // [])
        .grep({ .<items> && (%toc{.<url>}<part-number> // 0) > $published-limit })
        .map(*.<url>);
    return $html unless @locked;
    return $html.subst(
        / '<a' <-[>]>*? 'href="/' @locked [ '/' | '"' ] <-[>]>* '>' (.*?) '</a>' /,
        -> $m { "<span class=\"locked-link\">{$m[0]}</span>" },
        :g);
}

sub MAIN(:$language = '', :$filter = '', :$uri = '', :$destination = '_out', :$last-part = Inf,
         :$highlighter = 'pygments', :$workers = 1, Bool :check-code($check) = False) {
    # --highlighter=pygments (default) | rakupp | auto | none
    #   pygments : the Python highlighter (the historical reference output)
    #   rakupp   : Raku++'s own parse-aware `--highlight` (needs a `rakupp` binary)
    #   auto     : prefer pygments, fall back to rakupp
    #   none     : no syntax highlighting (plain, escaped code) — replaces the old --quick
    # --workers=N : render N pages in parallel (default 1 = sequential). Output is
    #   identical regardless of N. Parallelism only kicks in under Rakudo — run the
    #   generator as `raku raku-books.raku …`. Under `rakupp …` start/await do not
    #   thread, so --workers>1 is a no-op (same 1-worker time, no speedup).
    # --check-code : run every runnable Raku block through `raku -c` and add a
    #   `code-flagged` class to any that fail to compile (slower; off by default).
    $published-limit = +$last-part;
    $check-code = $check;
    for @languages.map: *.key -> $lang {
        next if $language && $lang ne $language;

        %toc = get-toc($lang, $filter ne '');
        generate-pages(%toc, $lang, $destination, $filter, $uri, $highlighter, $workers);
    }

    say "Done";
}
