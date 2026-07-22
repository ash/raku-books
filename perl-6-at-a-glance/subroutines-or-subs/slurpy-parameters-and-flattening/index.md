---
title: Slurpy parameters and flattening
---

{% include menu.html %}

Perl 6 allows passing scalars, arrays, hashes, or objects of any other type as the arguments to a sub. There are no restrictions regarding the combination and its order in a sub declaration. For example, the first argument may be an array, and the second one may be a scalar. Perl 6 will pass the array as a whole. Thus the following scalar will not be eaten by the array.

In the following example, the `@text` variable is used inside the sub, and it contains only the values from the array passed in the sub call.

```raku
sub cute-output(@text, $before, $after) {
    say $before ~ $_ ~ $after for @text;
}

my @text = <C C++ Perl Go>;
cute-output(@text, '{', '}');
```

The output looks quite predictable.

```
{C}
{C++}
{Perl}
{Go}
```

The language expects that the sub receives the arguments of the same types that were listed in the sub declaration.

That also means, for example, that if the sub is declared with only one list argument, then it cannot accept a few scalars.

```raku-static
sub get-array(@a) {
    say @a;
}

get-array(1, 2, 3); # Error: Calling get-array(Int, Int, Int)
                    # will never work with declared signature (@a)
```

To let an array accept a list of separate scalar values, you need to say that explicitly by placing an asterisk before the argument name. Such an argument is called slurpy.

```raku
sub get-array(*@a) {
    say @a;
}

get-array(1, 2, 3); # Good: [1 2 3]
```

Similarly, it will work in the opposite direction, that is to say, when the sub expects to get a few scalars but receives an array when called.

```raku-static
sub get-scalars($a, $b, $c) {
    say "$a and $b and $c";
}

my @a = <3 4 5>;
get-scalars(@a); # Error: Calling get-scalars(Positional)
                 # will never work with declared
                 # signature ($a, $b, $c)
```

A vertical bar is used to unpack an array to a list of scalars.

```raku-static
get-scalars(|@a); # 3 and 4 and 5
```

{% include nav.html %}
