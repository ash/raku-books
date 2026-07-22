---
title: 61. Number of occurrences in array
---

{% include menu.html %}

*Count how many times a particular element appears in the array.*

Let’s have an array with a list of fruits; some of them are repeated.

```raku-static
my @data = <
    apple       pear       grape     lemon
    peach       apple      banana    grape
    pineapple   avocado
>;
```

Now, the task is to count how many times the element `'grape'` appears there. First, extract all the elements to a temporary array by using the `grep` method, and then call the `elems` method to get the number of elements in the filtered data.

```raku-static
my $n = @data.grep('grape').elems;
say $n; # 2
```

Notice also a very handy way of defining arrays of strings. Instead of quoting all the elements, use the `<...>` syntax to create a list out of space-separated values.

If you need to determine the number of occurrences for more than one element, then it is better to use the more efficient technique to avoid `grep`ping the array for every item.

```raku-static
my %count;
%count{$_}++ for @data;

say %count<pineapple>; # 1
say %count<grape>;     # 2
```

{% include nav.html %}
