---
title: 17. The longest palindrome
---

{% include menu.html %}

*Find the longest palindromic substring in the given string.*

The main idea behind the solution is to scan the string with a window of varying width. In other words, starting from a given character, test all the substrings of any length possible at that position.

For the string `$string`, this is how the loops can be organized:

```raku-static
for 0 .. $length -> $start {
    for $start .. $length - 1 -> $end {
        . . .
    }
}
```

Now, extract the substring using the `substr` method, which is defined for the objects of the `Str` type, and do the check similar to the solution of Task 16, Palindrome test. Here, we have to be careful to check the palindrome without taking into account the non-letter characters but saving the result as part of the original string. For this, a copy of the substring is made.

```raku-static
my $substring = $string.substr($start, $length - $end);
my $test = $substring;
$test ~~ s:g/\W+//;
$test .= lc;
if $test eq $test.flip && $substring.chars > $found.chars {
    $found = $substring;
}
```

The temporary result is saved in the `$found` variable. The algorithm keeps track of the first longest palindromic substring. If there are more than one such substrings of the same length, they are ignored.

Here is the complete code of the program.

```raku-async
my $string = prompt('Enter string> ');
my $length = $string.chars;
my $found = '';

for 0 .. $length -> $start {
    for $start .. $length - 1 -> $end {
        my $substring =
            $string.substr($start, $length - $end);
        my $test = $substring;
        $test ~~ s:g/\W+//;
        $test .= lc;
        if $test eq $test.flip &&
           $substring.chars > $found.chars {
            $found = $substring;
        }
    }
}

if $found {
    say "The longest substring is '$found'.";
}
else {
    say "No palindromic substrings found.";
}
```

Run the program and see how it works.

```
Enter string> Hello, World!
The longest substring is 'o, Wo'.
```

As homework, modify the code so that it can track more than one palindromic substrings of the same length. It may, for example, keep the candidates in an array and re-initialize it if a longer palindrome is found.

{% include nav.html %}
