---
title: 59. First odd number
---

{% include menu.html %}

*Find the first odd number in a list of integers.*

The task is to find the first odd number in a given list of odd and even numbers. A good candidate is the `first` routine, which searches for the leftmost value (see, for example, Task 58, Is an element in a list?). Now, we can pass an anonymous code block to it to calculate the predicate.

```raku
my @nums = (2, 4, 18, 9, 16, 7, 10);
my $first = @nums.first: * % 2;
say $first; # Prints 9
```

Colon syntax is used here to pass arguments to methods. The same call may be written in the traditional style with parentheses:

```raku-static
my $first = @nums.first(* % 2);
```

The construction with a star (which is called Whatever) creates a code block with one argument, equivalent to `{$a % 2}`, that returns `True` when the number is odd. The same code can be rewritten less efficiently with a `grep`:

```raku-static
my @odd = grep {$_ % 2}, @nums;
say @odd[0]; # Prints 9
```

Let us try another method by matching the value against a regex that tests whether the last digit of a number is odd:

```raku-static
@nums ~~ /(\d*<[13579]>$)/;
say $/[0];
```

The whole array is matched against the regex, and the first captured value is printed.

{% include nav.html %}
