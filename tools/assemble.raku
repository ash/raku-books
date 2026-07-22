#!/usr/bin/env raku

# assemble.raku — build _data/toc/en.yaml from the per-book fragments, and
# generate the "Tested programs" register page from the per-book verdict files.
#
# Inputs (written by tools/extract.py):
#   tools/toc-<slug>.yaml       — a book's branch of the table of contents
#   tools/register-<slug>.json  — the Run-button verdict of every Raku program
#
# Outputs:
#   _data/toc/en.yaml           — combined TOC (+ a "Tested programs" entry)
#   tested-programs/index.md    — the register page
#
# Books appear newest-first (reverse chronological by the `date` field).

use YAMLish;   # loads the PyYAML fragments and the JSON registers (JSON is YAML)

my $ROOT = $*PROGRAM.parent.parent;

# ── the Tested-programs register page ───────────────────────────────────
sub register-page(@regs) {
    return '' unless @regs;

    my %total;
    for @regs -> $r { %total{.<state>}++ for @($r<verdicts>) }
    my $grand = %total.values.sum;

    my @out;
    @out.push: q:to/INTRO/.chomp;
    Every complete Raku program in these books is **compiled and run at build time** under two compilers — [Rakudo](https://rakudo.org) (the reference implementation) and [Raku++](https://github.com/ash/rakupp) (the engine that runs code in your browser via [Raku.js](https://raku.online)). A program gets a **Run** button only when it runs under Rakudo *and* Raku++ reproduces the same output.
    INTRO

    @out.push: "Of **$grand** Raku programs across the books: "
        ~ "**{%total<run> // 0}** run in the browser, "
        ~ "**{%total<fragment> // 0}** are illustrative fragments (no Run button), "
        ~ "**{%total<env> // 0}** need a local environment (files or the command line), "
        ~ "**{%total<concurrent> // 0}** use concurrency the single-threaded in-browser "
        ~ "engine can't run, and **{%total<rakupp> // 0}** are valid programs the "
        ~ "in-browser engine cannot run correctly yet.\n";

    my sub listing($state, $heading, $blurb) {
        my (@rows, %seen);
        for @regs -> $r {
            for @($r<verdicts>) -> $v {
                next unless $v<state> eq $state;
                my $key = "$r<slug>|$v<url>";
                next if %seen{$key}++;
                @rows.push: [$r<book>, $v];
            }
        }
        return unless @rows;
        @out.push: "## $heading\n";
        @out.push: "$blurb\n";
        @out.push: "| Program | Book | Why |";
        @out.push: "|---------|------|-----|";
        for @rows -> $row {
            my ($book, $v) = $row[0], $row[1];
            @out.push: '| [' ~ ($v<label> || '(program)') ~ '](' ~ $v<url>
                ~ ') | ' ~ $book ~ ' | ' ~ $v<reason> ~ ' |';
        }
        @out.push: "";
    }

    listing('env', 'Programs that need a local environment',
            "These are complete, valid Raku programs, but they read the filesystem, "
            ~ "spawn processes, or use the command line — things the sandboxed "
            ~ "in-browser engine has no access to. They run fine on your own computer.");

    listing('concurrent', 'Programs that use concurrency',
            "These use promises or threads. The in-browser engine (Raku.js) is "
            ~ "single-threaded, so real parallelism deadlocks — run these on your own "
            ~ "computer.");

    listing('rakupp', 'Programs the in-browser engine can’t run yet',
            "These are complete, valid Raku programs, but Raku++ errors or prints "
            ~ "something different from Rakudo — a gap to close in the browser engine. "
            ~ "Each page still shows the program’s expected output.");

    @out.push: "## Verified-runnable programs\n";
    for @regs -> $r {
        my (@runs, %seen);
        for @($r<verdicts>) -> $v {
            next unless $v<state> eq 'run';
            next if %seen{$v<url>}++;
            @runs.push: $v;
        }
        next unless @runs;
        @out.push: '<details><summary><strong>' ~ $r<book> ~ '</strong> — '
            ~ @runs.elems ~ " programs</summary>\n";
        @out.push: "<div markdown=\"1\">\n";
        @out.push: '* [' ~ .<label> ~ '](' ~ .<url> ~ ')' for @runs;
        @out.push: "\n</div>\n</details>\n";
    }

    return @out.join("\n");
}

sub MAIN() {
    my %conf = load-yaml("$ROOT/tools/books.yaml".IO.slurp);

    # Newest first (string ISO dates sort correctly).
    my @books = %conf<books>.pairs.sort({ .value<date> // '' }).reverse;

    my (@toc, @regs);
    for @books -> $p {
        my $slug = $p.value<slug>;
        my $frag = "$ROOT/tools/toc-$slug.yaml".IO;
        if $frag.e {
            my @entries = @(load-yamls($frag.slurp)[0]);
            # Inject the "get the book" link from books.yaml (kept out of the
            # committed fragments so it can change without re-extracting).
            @entries[0]<get_url> = $p.value<get_url> if $p.value<get_url>;
            @toc.push: $_ for @entries;
            say "  + $slug";
        } else {
            say "  (skip {$p.key}: no fragment yet)";
        }
        my $reg = "$ROOT/tools/register-$slug.json".IO;
        @regs.push: load-yaml($reg.slurp) if $reg.e;
    }

    my $body = register-page(@regs);
    if $body {
        my $head = q:to/HEAD/;
        ---
        title: Tested programs
        ---

        {% include menu.html %}

        HEAD
        mkdir "$ROOT/tested-programs";
        "$ROOT/tested-programs/index.md".IO.spurt($head ~ $body ~ "\n");
        @toc.push: { title => 'Tested programs', url => 'tested-programs' };
        say "  + tested-programs (register)";
    }

    my %site = title => 'Andrew Shitov’s Raku Books', url => '', toc => @toc;
    my $out = "$ROOT/_data/toc/en.yaml".IO;
    mkdir $out.parent;
    $out.spurt(save-yaml(%site));
    say "→ {$out}  ({@toc.elems} entries)";
}
