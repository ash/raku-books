---
title: 66. Variadic parameters in a sub
---

{% include menu.html %}

*Pass a few scalars to a sub and work with them as with an array inside the sub.*

The task is to take a few scalar parameters and pass them to a single array in the subroutine.

Here is an example of how to do that, prefixing an array name with a star:

```raku
sub h($sep, *@data) {
    @data.join($sep).say;
}

h(', ', 'red', 'green', 'blue');
```

The `*@data` struct is called a slurpy parameter. It is an array that consumes all of the arguments passed to the function after the `$sep` argument. In the example above, three string values are passed. It is also possible to pass any other number of arguments:

```raku-static
h(', ', 'apple');

h(', ', 1, 2, 3, 4, 5);
```

Or even as a range of values, all of which land in the `@data` array.

```raku-static
h(', ', 'a' .. 'z');
```

It is important that in comparison to the solutions from Task 65, Passing arrays to subroutines, the `$sep` argument is mentioned first in the sub signature. If you put it at the end, the compiler refuses to accept that and complains:

```raku-static
Cannot put required parameter $sep after variadic parameters
```

{% include nav.html %}
