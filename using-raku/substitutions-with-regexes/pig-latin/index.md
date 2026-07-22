---
title: 81. Pig Latin
---

{% include menu.html %}

*Convert the given text to Pig Latin.*

Pig Latin is a pseudo-language, each word of which is derived from the corresponding English word, following a couple of simple rules:

*1. If the word starts with consonant letters (including consonant sounds represented by letter combinations such as qu), move them all to the end of the word. 2. Append the ay ending.*

Here is a program that implements this algorithm.

```raku-nobrowser
my $text = prompt('English > ');

$text ~~ s:i:g/ << ([qu]? <-[aeiou]>+) (\w*) >> /$1$0/;
$text ~~ s:i:g/ << (\w+) >> /$0ay/;

say $text; # you are welcome → ouyay areay elcomeway
```

For simplicity, both steps are done via their own regex replacements. The first one finds the words that starts with either qu or with a character that is not a vowel (in other words, which is neither a, e, i, o, or u). The two captured parts of the word are switched in the replacement part: `$1$0`.

The second substitution instruction finds all the words (at this point, the words that had initially started with consonants are already modified and the words, starting with vowels, stay original) and appends the ay ending to it.

The `<<` and `>>` anchors bind the regexes to word borders.

As an exercise, modify the program to take care of capital letters in the original sentence so that You becomes Ouyay and not ouYay.

{% include nav.html %}
