---
title: User-defined functions
---

{% include menu.html %}

Everything we did with functions so far was about the fixed set of built-ins. A real language lets the user create their own functions, and this is what we implement in the rest of this chapter. As always, let us first design the syntax:

```raku-static
func add(a, b) {
    return a + b;
}
say add(3, 4);
```

A function is introduced by the `func` keyword, followed by a name, a comma-separated list of parameters in parentheses, and a body in curly braces. Unlike the built-in functions, which are called without parentheses, a user-defined function is called with its arguments in parentheses. Keeping the two syntaxes different is not only simpler to parse. It also lets the reader of a program immediately see whether a function is a part of the language or a part of the program.

{% include nav.html %}
