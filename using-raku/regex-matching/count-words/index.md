---
title: 73. Count words
---

{% include menu.html %}

*Count the number of words in a text.*

Before solving the task, let us assume that by words we mean here a sequence of alphanumeric characters, including the underscore symbol.

Here is the solution:

```raku-static
my $text = prompt('Text> ');
say $text.comb(/\w+/).elems;
```

Try it on a few test inputs:

```
$ raku countwords.rk
Text> Hello, World;
```

The program uses regexes for extracting words using the `\w` character class and the `comb` string method that returns a sequence of the words:

```raku-static
$text.comb(/\w+/)
```

The `+` quantifier allows a repetition of `\w`, so it matches the whole word.

Alternatively, a more traditional match with a regex may be used:

```raku-static
$text ~~ m:g/(\w+)/;
say $/.elems;
```

Parentheses in the regex capture the word, and the `:g` adverb applies it a few times until all the words are found. The `$/` variable (called the match object) keeps all the matched substrings, and the `elems` method returns the number of elements in it.

{% include nav.html %}
