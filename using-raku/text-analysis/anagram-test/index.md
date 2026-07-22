---
title: 15. Anagram test
---

{% include menu.html %}

*Tell if the two words are anagrams of each other.*

Anagrams are words or phrases that are built out of the same letters. We start with checking words only.

```raku-static
my $a = prompt('First word > ');
my $b = prompt('Second word > ');

say normalize($a) eq normalize($b)
    ?? 'Anagrams.' !! 'Not anagrams.';

sub normalize($word) {
    return $word.comb.sort.join('');
}
```

The words, stored in the `$a` and `$b` variables, are passed through the `nor-` `malize` function, which converts a word into a string, where all the letters are alphabetically sorted. For example, the ‘hello’ string becomes ‘ehllo’. If both words can be normalised to the same form, they are anagrams.

To make the program accept phrases, let’s modify the `normalize` function so that it removes the spaces from the phrase and makes all the letters lowercase:

```raku-static
sub normalize($word) {
    return $word.lc.comb.sort.join('').trans(' ' => '');
}
```

There are two additions to the above chain of method calls: `lc` converts the string to the lowercase version, and the `trans` method replaces all the spaces with an empty string. After these changes, the ‘Hello World’ phrase becomes ‘dehllloorw’.

{% include nav.html %}
