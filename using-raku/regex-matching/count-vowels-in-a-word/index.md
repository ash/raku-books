---
title: 72. Count vowels in a word
---

{% include menu.html %}

*Count the number of vowel letters in the given word.*

Of course, we will abstract now from the difference between letters and sounds and will only count the number of vowel letters: a, e, i, o, and u.

```raku
my $word = 'Hello';
$word ~~ m:g:i/<[aeiou]>/;
say $/.elems;
```

Here, the given `$word` is matched against a regex that contains a character class with all the letters of our interest. Character classes in regexes use the `<[...]>` syntax. The regex is prefixed with the `:g` adverb, making it match as many times as needed to cover the whole string. The second adverb, `:i`, makes the regex case-insensitive.

The result of the match is a match object `$/`, which contains all the occurrences of vowel letters found in the word. Its length is the number we need. So, printing `$/.elems` gives the answer.

To extend the match to allow characters with diacritics, such as ü, the simplest is to add another adverb, `:m`, as shown in the next example.

```raku-static
$word = 'Münich';
$word ~~ m:g:i:m/<[aeiou]>/;
say $/.elems;
```

This program prints `2`, as both `ü` and `i` matched.

If you prefer the long adverb names, here is the code:

```raku-static
$word ~~ m:global:ignorecase:ignoremark/<[aeiou]>/;
```

{% include nav.html %}
