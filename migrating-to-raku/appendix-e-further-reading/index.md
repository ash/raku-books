---
title: Appendix E — Further Reading
---

{% include menu.html %}

This book gets you across the bridge from Perl; the Raku community keeps you
moving once you are on the other side. What follows is a curated set of
starting points — the official documentation, the tooling, the places people
gather, and the books worth owning — accurate as of 2026. Links change over the
years, so when one has moved, a quick search for its name will usually find its
new home.

## Official documentation and language sites

- **The Raku documentation** — <https://docs.raku.org> — the reference for the
  language, its types, and its built-in routines. The type-reference pages and
  the "Language" tutorials are where you will spend most of your time. The whole
  site is searchable and can be installed offline.
- **raku.org** — <https://raku.org> — the language's home page, with pointers to
  everything else and a gentle overview for newcomers.
- **The Raku design documents** — <https://design.raku.org> — the historical
  "Synopses" and "Apocalypses". Not a tutorial, but useful when you want to
  understand *why* a corner of the language is shaped as it is.

## Compiler and tooling

- **Rakudo** — <https://rakudo.org> — the reference compiler you have been
  running throughout this book, with download and build instructions for every
  platform. The recommended distribution bundles Rakudo with the `zef`
  installer.
- **zef** — the module installer (`zef install Foo`, `zef update`). It ships
  with the standard distribution; its project page documents the full command
  set (Chapter 25).
- **Comma / editor support** — plugins exist for the major editors; syntax
  highlighting and a REPL cover most day-to-day needs.

## The module ecosystem

- **raku.land** — <https://raku.land> — the modern, searchable front end to the
  Raku module ecosystem. Browse here before writing something from scratch;
  much of what you reached for on CPAN has a counterpart.
- **The Raku ecosystem** is where `zef` pulls modules from; `META6.json` is the
  metadata file that describes each distribution (Chapter 25).
- **Inline::Perl5** — when a Raku equivalent does not yet exist, this module
  lets you call straight into CPAN from Raku, so the whole of Perl remains
  within reach (Chapter 25).

## Community

Raku's community is small, friendly, and unusually welcoming to questions from
Perl programmers — many of its members made the same move you are making.

- **IRC** — the `#raku` channel on **Libera.Chat** (<https://libera.chat>) is the
  historical heart of the community and still active. A companion `#raku-beginner`
  channel exists for gentler questions.
- **Discord** — a bridged Raku server carries the same conversations for those
  who prefer it.
- **Stack Overflow** — the `[raku]` tag
  (<https://stackoverflow.com/questions/tagged/raku>) is well tended; answers
  often come from core developers.
- **Reddit** — <https://reddit.com/r/rakulang> — announcements, blog posts, and
  discussion.

## Learning resources and regular reading

- **Raku Advent Calendar** — <https://raku-advent.blog> — a new article every day
  through December each year, ranging from beginner tutorials to deep dives. Its
  back catalogue is one of the best free libraries of Raku writing anywhere.
- **Rakudo Weekly News** — <https://rakudoweekly.blog> — a weekly digest of what
  happened in the ecosystem: releases, blog posts, and discussions. The fastest
  way to stay current.
- **Exercism — Raku track** — <https://exercism.org/tracks/raku> — graded
  exercises with mentor feedback, an excellent way to build fluency by writing
  small programs.
- **Rosetta Code** — <https://rosettacode.org> — hundreds of tasks solved in
  Raku alongside other languages, including Perl, so you can compare
  idioms side by side.

## Books

Several good books cover Raku in more depth or from a different angle than this
one.

By **Andrew Shitov** (the author of this book), whose titles span the language's
Perl 6 and Raku eras:

- **Using Raku** — a collection of one hundred worked problems and their
  solutions, a practical companion for building everyday fluency.
- **Raku One-Liners** — short, self-contained programs that show the language's
  expressive power in a line or two; a natural follow-on to Chapter 29.
- **Perl 6 Deep Dive** — a broad, example-driven tour of the language from its
  Perl 6 days; still relevant, allowing for the rename to Raku.
- **Course of Raku** — the companion course to this book, a structured,
  ground-up path through the language for those who want a full curriculum
  rather than a migration guide.

By other authors:

- **Learning Perl 6 / Learning Raku**, by *brian d foy* (O'Reilly) — a
  from-scratch introduction; published under both names across editions.
- **Perl 6 Fundamentals** and **Parsing with Perl 6 Regexes and Grammars**, by
  *Moritz Lenz* (Apress) — the second is the book to read after Chapter 19 if
  grammars catch your interest.
- **Think Perl 6 / Think Raku**, by *Laurent Rosenfeld with Allen Downey*
  (O'Reilly) — a computer-science introduction using Raku, available free
  online.

Where a title has been reissued under both the "Perl 6" and "Raku" names, the
content is the same language — only the branding changed. When in doubt about
which edition is current, check the author's site or the publisher's page.

That is the end of the appendices, and of the book. You came in fluent in
Perl; you leave able to read, write, and reason about Raku. The rest is
practice — and the community above is there for the questions this book did not
anticipate. Welcome to Raku.

{% include nav.html %}
