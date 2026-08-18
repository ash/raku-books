---
title: Preface
---

{% include menu.html %}

Perl 6 has been around for a long time. Its story began around 2000, and after a
number of turbulent years, in 2015 we got the first stable specification, 6.c,
together with a working and stable compiler, Rakudo. The language later gained a
new name — **Raku** — but the intent of this book is unchanged: to help you, a
fluent Perl programmer, start writing Raku.

This is not a book that teaches programming, and it is not a book that teaches
Raku from an empty page. It assumes you already think in Perl: you reach for a
hash without hesitation, you know what a slurpy `@_` feels like, and you have a
favourite way to slurp a file. What you want is a **translation guide** — an
item-by-item recipe that takes each pattern you already know and shows how it
looks in Raku, what changed, and *why*.

A note on names. The language you are coming from is simply **Perl** — for years
it was disambiguated as "Perl 5", but with Perl 6 now long since renamed to Raku,
that distinction has served its purpose, so this book just says "Perl", and names
a version number only when a specific release matters (as in "Perl 5.10
introduced `say`"). The language you are moving to is **Raku**; you may still see
its former name, "Perl 6", in older books and articles.

To run the examples, install the latest Rakudo (the Rakudo Star distribution is
the easiest starting point) from [rakudo.org](https://rakudo.org). Rakudo is the
reference compiler, and every Raku output printed in this book was checked
against it.

You have a second option, too. **Raku++** — the `rakupp` command — is a
brand-new, independent implementation of Raku, written from scratch in C++ with
no dependency on Rakudo. It is a young project and does not yet cover every
corner of the language, but it is fast, self-contained, and already runs a large
share of the programs in this book. If you would like to follow along with it,
run a program with `rakupp program.raku` exactly as you would with `raku`; where
an example relies on a feature Raku++ has not implemented yet, fall back to
Rakudo, which remains the reference throughout.

In the chapters that follow we work with **both** Perl and Raku, so it is
assumed you have both installed, and that your Perl is no older than 5.12.

{% include nav.html %}
