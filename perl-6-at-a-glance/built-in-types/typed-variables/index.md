---
title: Typed variables
---

{% include menu.html %}

This is how you declare a typed variable:

```raku-static
my Int $x;
```

Here, a scalar container `$x` may only hold an integer value. Attempts to assign it a value that is not an integer leads to an error:

```raku-static
my Int $x;
$x = "abc"; # Error: Type check failed in assignment to '$x';
            # expected 'Int' but got 'Str'
```

For typecasts, a respective method call is quite handy. Remember that while `$x` holds an integer, it is treated as a container object as a whole, which is why you may use some predefined methods on it. The same you can do directly on a string. For example:

```raku
my Int $x;
$x = "123".Int; # Now this is OK
say $x; # 123
```

{% include nav.html %}
