---
title: 78. Separate digits and letters
---

{% include menu.html %}

*In a given string that contains letters and digits, insert dashes on the borders between the digit and letter sequences.*

The goal of the task is to convert, for example, the string `6TGT68` to `6-TGT-` `68`. With some modification, this task may be needed for creating the canonical form of car license plates in some countries.

There are character classes in the Raku regexes: `<:alpha>` for alphabetical characters and `<:digit>` for digits. Let us use them for finding the borders between digits and letters. In other words, we need to find all the sequences of two characters, where one of them is a letter and another is a digit.

```raku-nobrowser
my $s = '6TGT68';

$s ~~ s:g/
    (<:alpha>) (<:digit>) |
    (<:digit>) (<:alpha>)
/$0-$1/;

say $s; # 6-TGT-68
```

The replacement construct `s:g///` is applied globally. It finds all the places, which match either `<:alpha> <:digit>` or `<:digit> <:alpha>`.

When the match is found, the `$0` and `$1` variables are set to either a letter and a digit or to a digit and a letter. The parentheses indices count from zero in each alternative separated with a vertical bar.

The replacement uses the found characters and inserts a hyphen character between them. Notice that the spaces in the regex are allowed and ignored, while the spaces in the replacement part are significant, so the `/$0-$1/` part should not contain additional spaces.

{% include nav.html %}
