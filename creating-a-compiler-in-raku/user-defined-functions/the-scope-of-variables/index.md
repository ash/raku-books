---
title: The scope of variables
---

{% include menu.html %}

Look again at the lines that save and restore the variable storage. They give our functions an important property, a local scope:

```raku-static
my x = 100;
func double(a) {
    my x = a * 2;
    return x;
}
say double(3); ## 6
say x; ## 100
```

The `x` inside the function and the `x` outside are two different variables. When a function is entered, only its parameters exist; the globals are not visible from inside. This makes Lingua functions self-contained: everything a function needs must be passed as an argument. It is a deliberate design decision. Many scripting languages choose the opposite and let the functions read the globals; you can easily get that behaviour by copying `%!var` instead of emptying it.

The chain of saved storages effectively forms the call stack of our language: each nested call stores one more frame, and each return restores one. We get the right behaviour for nested and, more importantly, recursive calls without any additional code.

{% include nav.html %}
