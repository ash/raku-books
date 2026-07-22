---
title: Function overloading
---

{% include menu.html %}

The `multi` keyword allows defining more than one function (or subroutine, or simply sub) with the same name. The only restriction is that those functions should have different signatures. In Perl 6, the signature of the sub is defined together with its name, and the arguments may be typed. In the case of multi subs, typed arguments make even more sense because they help to distinguish between different versions of the function with a single name and make a correct choice when the compiler needs to call one of them.

```raku
multi sub twice(Int $x) {
    return $x * 2;
}
multi sub twice(Str $s) {
    return "$s, $s";
}
say twice(42);   # 84
say twice("hi"); # hi, hi
```

```

```

As we have two functions here, one taking an integer argument and another expecting a string, the compiler can easily decide which one it should use.

{% include nav.html %}
