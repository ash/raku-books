---
title: 4. Unique digits
---

{% include menu.html %}

*Print unique digits from a given integer number.*

The task is easily solved if an integer is immediately converted to a string.

```raku-static
my $number = prompt('Enter number> ');
say $number.comb.unique.sort.join(', ');
```

The `comb` method, called with no arguments, splits the string into separate characters. The method is defined in the `Str` class; thus, the `$number` is converted to the string first. The same may be explicitly written as:

```raku-static
$number.Str.comb
```

Notice that in the case of using `$number.split('')`, empty elements are added to the beginning and the end of the array.

At this moment, an initial number resides in an array, each element of which is a digit from the `$number`.

Taking unique elements of an array does not require any manual programming, as the `Array` class contains a special method for that:

```raku-static
$number.comb.unique
```

Finally, to make the result look better, the array of unique digits is sorted and printed as a comma-separated list:

```raku-static
$number.comb.unique.sort.join(', ')
```

Instead of calling `say` as a stand-alone function, it may be called as a method on the resulting string:

```raku-static
$number.comb.unique.sort.join(', ').say;
```

{% include nav.html %}
