---
title: 65. Passing arrays to subroutines
---

{% include menu.html %}

*Pass data, contained in an array, to a subroutine.*

An array can be passed to a subroutine as easily as a scalar can. You simply define it in a signature and pass it together with other arguments.

```raku
my @colours = <red green blue>;

sub f(@data, $sep) {
    @data.join($sep).say;
}

f(@colours, ', '); # Prints: red, green, blue
```

The `@colours` array is passed to the `f` sub, and it lands in the `@data` variable inside the sub. An additional second argument, `$sep`, receives its own data.

In cases when a sub expects separate scalars, and you’ve got your data in an array, flattening it helps:

```raku-static
sub g($a, $b, $c, $sep) {
    say "$a$sep$b$sep$c";
}
g(|@colours, ', '); # Prints: red, green, blue
```

In the sub call, an array name is prefixed with a vertical bar, and the compiler, therefore, knows that you are not passing an array as a whole but that you are using its elements as values to be assigned to the scalar arguments `$a`, `$b`, and `$c`.

The number of elements in the array has to match with the number of corresponding subroutine arguments, otherwise one of the following errors oc-

```
curs: Too few positionals passed or Too many positionals passed.
```

{% include nav.html %}
