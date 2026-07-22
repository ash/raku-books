---
title: 7. Camel case
---

{% include menu.html %}

*Create a camel-case identifier from a given phrase.*

It is a good practice to follow some pattern when choosing names for variables, functions, and classes in any programming language. In Raku, identifiers are case-sensitive, and, unlike many other languages, hyphens are allowed. So, variables names like `$max-span` or function names like `celsius-to-` `fahrenheit` are accepted.

In this task, we will form the `CamelCase` variable names from a given phrase. Names created in this style are built of several words; each of which starts with a capital letter.

Here’s the program that does the required conversions:

```raku-static
my $text = prompt('Enter short text > ');
my $CamelName = $text.comb(/\w+/).map({.tclc}).join('');
say $CamelName;
```

All the actions are done in a sequence of method calls. The words are selected from the input `$text` using the `comb` method with a regex `/\w+/`. Then, each found word is `map`ped using the `tclc` method, which is equivalent to the chained call `.lc.tc`:

A ‘bare’ dot means that the method is called on the default variable `$_`, which is repeatedly set to the current element. In Raku, there is no `ucfirst` method to make the first letter of the text uppercase. Instead, we are using the `tclc` method; tc stands for Title Case, lc for Lower Case, and all the letters are converted to lowercase except the first one.

Finally, the elements of the array are joined together with the help of the `join` method. The input string ‘Hello, World!’ becomes `HelloWord` after all the transformations are done.

{% include nav.html %}
