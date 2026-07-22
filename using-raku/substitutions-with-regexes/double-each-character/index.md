---
title: 76. Double each character
---

{% include menu.html %}

*In a given string, double each alphanumeric character and print the result. Punctuation and spaces should stay untouched.*

Regexes are very powerful tools for searching and replacing texts. In this task, only the alphanumeric characters are requested to be doubled. The `\w` character class is the perfect match to find these characters.

```raku
my $string = 'Hello, 1 World!';
$string ~~ s:g/(\w)/$0$0/;
say $string;
```

We are using the `s///` construct here. The `$string` is matched against the `\w` regex. The parentheses around `\w` capture the found character. It is now contained in the `$0` special variable.

In the second part of the replacement, `$0` is used twice, and, thus, the doubled character is replacing the single character found in the string. The `:g` adverb makes the replacement global.

The program prints the following output:

```
HHeelllloo, 11 WWoorrlldd!
```

Let us update the program to exclude the `r` letter from the process. In other words, all the characters, except `r`, must be doubled. Build a new character class as a difference between `\w` and `r` as demonstrated in the following line of code:

```raku-static
$string ~~ s:g/(<[\w] - [r]>)/$0$0/;
```

Now, the output is a bit different: `HHeelllloo, 11 WWoorldd!`

{% include nav.html %}
