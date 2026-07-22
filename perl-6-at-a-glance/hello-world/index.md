---
title: Hello, World!
---

{% include menu.html %}

The Perl 6 compiler can either read a programme from a file or from the content of the `-e` command line switch. The simplest “Hello, World!” programme looks like this:

```raku
say "Hello, Perl 6!";
```

Save it in a file and run:

```
$ perl6 hello.pl
Hello, Perl 6!
```

Alternatively, you may use the `-e` option:

```
$ perl6 -e'say "Hello, Perl 6!"'
Hello, Perl 6!
```

{% include nav.html %}
