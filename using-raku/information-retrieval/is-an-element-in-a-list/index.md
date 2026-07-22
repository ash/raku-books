---
title: 58. Is an element in a list?
---

{% include menu.html %}

*Tell if the given value is in the list.*

There are a few approaches to the problem. The most compact one seems to be the use of the smartmatch `~~` operator in combination with the `any` function:

```raku
my @array = (10, 14, 0, 15, 17, 20, 30, 35);
my $x = 17;
say 'In the list' if $x ~~ any @array;
```

To check if a given value is contained among the elements of an array or a list, use the `grep` routine.

```raku-static
say 'In the list' if grep $x, @array;
```

The `grep` routine returns a list of all the matched elements. In the Boolean context, the return value is `True` if at least one element was found. In the opposite case, an empty list coerces to `False`. If the element in question is not zero, then the `first` routine may be used instead of grep. It returns the first element that matches the search pattern:

```raku-static
say 'In the list' if first $x, @array;
```

To extend this to zero values, test the values before making a decision:

```raku-static
say 'In the list' if $x == first $x, @array;
```

Another solution is to convert the array to a hash and check if there is a key with the given value. This is useful when you need more than one check.

```raku-static
my %hash = map {$_ => 1}, @array;
say 'In the list' if %hash{$n};
```

{% include nav.html %}
