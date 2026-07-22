---
title: Regexes
---

{% include menu.html %}

In fact, Perl 6 just calls regular expressions regexes. The basic syntax is a bit different from Perl 5, but most elements (such as quantifiers `*` or `+`) still look familiar. The `regex` keyword is used to build a regex. Let us create a regex for the short names of weekdays.

```raku-static
my regex weekday
    {[Mon | Tue | Wed | Thu | Fri | Sat | Sun]};
```

The square brackets are enclosing the list of alternatives.

You can use the named regex inside other regexes by referring to its name in a pair of angle brackets. To match the string against a regex, use the smartmatch operator (`~~`).

```raku-static
say 'Thu' ~~ m/<weekday>/;
say 'Thy' ~~ m/<weekday>/;
```

```

```

These two matches will print the following.

```
「Thu」
  weekday => 「Thu」
False
```

The result of matching is an object of the `Match` type. When you print it, you will see the matched substring inside small square brackets 
`「`...`」`.

Regexes are the simplest named constructions. Apart from that, rules and tokens exist (and thus, the keywords `rule` and `token`).

Tokens are different from rules first regarding how they handle whitespaces. In rules, whitespaces are part of the regexes. In tokens, whitespaces are just visual separators. We will see more about this in the examples below.

```raku-static
my token number_token { <[\d]> <[\d]> }
my rule number_rule { <[\d]> <[\d]> }
```

(Note that there is no need in semicolons after the closing brace.)

The `<[...]>` construction creates a character class. In the example above, the two-character string `42` matches with the `number_token` token but not with the `number_rule` rule.

```raku-static
say 1 if "42" ~~ /<number_token>/;
say 1 if "4 2" ~~ /<number_rule>/;
```

```

```

{% include nav.html %}
