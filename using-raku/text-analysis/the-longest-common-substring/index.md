---
title: 14. The longest common substring
---

{% include menu.html %}

*Find the longest common substring in the given two strings.*

Let us limit ourselves with finding only the first longest substring. If there are more common substrings of the same length, then the rest are ignored. There are two loops (see also Task 17, The longest palindrome) over the first string (`$a`), and they use the `index` method to search for the substring in the second string (`$b`).

```raku-async
my $a = 'the quick brown fox jumps over the lazy dog';
my $b = 'what does the fox say?';

my $common = '';
for 0 .. $a.chars -> $start {
    for $start ..^ $a.chars -> $end {
        my $s = $a.substr($start, $a.chars - $end);
        if $s.chars > $common.chars && $b.index($s).defined {
            $common = $s;
        }
    }
}

say $common
    ?? "The longest common substring is '$common'."
    !! 'There are no common substrings.';
```

The `index` method returns the position of the substring `$s` if it is found in the string `$b`. It is a little bit tricky to check if the substring is found because when it is found at the beginning of the string, then the returned value is `0` (as `0` is the position of the substring). If the substring is not found, then `Nil` is returned. `Nil` is not a numeric value; thus, it cannot be compared using the `==` or `!=` operators. Use the `defined` method to check if `index` returns a value, not `Nil`: `$b.index($s).defined`.

{% include nav.html %}
