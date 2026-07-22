---
title: Creating a Simple Translator
---

{% include menu.html %}

Let’s start exploring the power of Raku’s grammars and regexes from a simple translator program that parses and executes the following tiny program. I will call this language Lingua.

```raku-static
my x;
x = 42;
say x;
```

You should not experience any problems with understanding what this code means, as the syntax is deliberately chosen to resemble the Perl syntax. Just no sigils in front of the variable names.

The program declares a variable named `x`, assigns an integer value to it and then prints the value to the console.

Suppose you saved the code in a file, say, `test.lng`. Let us now read it with Raku.

```raku-local
my $code = 'test.lng'.IO.slurp();
say $code;
```

Save this Raku program in another file, `lingua.pl,` and run it:

```
$ raku lingua.pl
```

If you have Raku installed, you’ll get the content of our test program printed.

{% include nav.html %}
