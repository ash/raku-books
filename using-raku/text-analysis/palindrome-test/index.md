---
title: 16. Palindrome test
---

{% include menu.html %}

*Check if the entered string is palindromic.*

A palindrome is a string that can be read from both ends: left to right or right to left. First, start with the simple case when the string contains only letters. (Thus, spaces and punctuation do not affect anything.)

In Task 5, Reverse a string, the `flip` method is used to reverse a string. To check whether it is a palindrome, compare the string with its flipped version.

```raku-static
my $string = prompt('Enter a string: ');
my $is_palindrome = $string eq $string.flip;

say 'The string is ' ~
    (!$is_palindrome ?? 'not ' !! '') ~
    'palindromic.';
```

This code works well with single words like ABBA or madam or kayak.

Let us take the next step and teach the program to work with sentences that contain spaces and punctuation characters. For removing all the non-letter characters, regexes are a good choice:

```raku-static
$string ~~ s:g/\W+//;
```

The `\W+` regex matches with all non-word characters. All occurrences of them are removed from the string (replaced with nothing). The `:g` adverb tells the regex to repeatedly scan the whole string.

Additionally, the string should be lowercased:

```raku-static
$string .= lc;
```

The `lc` method is called on `$string`, and the result is assigned back to the same variable. This construction is equivalent to the following:

```raku-static
$string = $string.lc;
```

Add these two lines to the program:

```raku-static
my $string = prompt('Enter a string: ');

$string ~~ s:g/\W+//;
$string .= lc;

my $is_palindrome = $string eq $string.flip;

say 'The string is ' ~
    (!$is_palindrome ?? 'not ' !! '') ~
    'palindromic.';
```

Check the modified program against a few random sentences and a few palindromes:

*Never odd or even.*

*Was it a rat I saw?*

*Mr. Owl ate my metal worm.*

That’s all. As an additional stroke, it is a good thing to simplify the concatenated string a bit and use interpolation:

```raku-static
my $string = prompt('Enter a string: ');
$string ~~ s:g/\W+//;
$string .= lc;

my $is_palindrome = $string eq $string.flip;
my $not = $is_palindrome ?? '' !! ' not';
say "The string is$not palindromic.";
```

{% include nav.html %}
