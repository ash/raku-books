---
title: Prerequisites
---

{% include menu.html %}

You need a Raku compiler. Visit rakudo.org and download the latest version of the Rakudo Star compiler. The code of the book works well with Rakudo Star version 2019.03, but you could use earlier versions down to 2017.09.

NB! To run Raku programs from the command line, you need to run the `raku` command (which, obviously, runs the compiler). In the meantime, before the rename is complete, you can either run the `perl6` command, or create an alias in your `.profile` file:

```
alias raku=perl6
```

You need a text editor, too. By default, Raku assumes that the source code is saved using UTF-8 encoding and, as some language constructs may use Unicode characters, it is better if your editor supports it.

If you are not yet familiar with Raku, read at least one of the following introductory books first:

Andrew Shitov, Perl 6 at a Glance DeepText — 2017, ISBN 978-90-821568-3-6

Andrew Shitov, Perl 6 Deep Dive Packt Publishing — 2017, ISBN 978-1-78728-204-9

If you need to improve your knowledge about programming in general, read another book, too:

*Laurent Rosenfeld, Allen B. Downey, Think Perl 6*

O’Reilly Media — 2017, ISBN 978-1-4919-8055-2

The source codes of all the examples in the book are located in the GitHub repository: github.com/ash/p6challenges.

{% include nav.html %}
