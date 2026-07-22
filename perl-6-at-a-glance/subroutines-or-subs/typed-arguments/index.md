---
title: Typed arguments
---

{% include menu.html %}

Similarly to the above-described typed variables, it is possible to indicate that the sub’s parameters are typed. To do so, add a type name before the name of the parameter.

```raku-static
sub say-hi(Str $name) {
    say "Hi, $name!";
}
```

If the types of the expected and the actual parameters do not match, a compile-time error will occur.

```raku-static
say-hi("Mr. X"); # OK
```

```raku-static
# say-hi(123); # Error: Calling say-hi(Int) will never work
               # with declared signature (Str $name)
```

{% include nav.html %}
