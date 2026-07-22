---
title: Better variable names
---

{% include menu.html %}

Before the end of this chapter, let us make a couple of more small but very fruitful additions. Earlier, we made an ad-hoc token for parsing variable names:

```raku-static
token variable-name {
    \w+
}
```

This token matched the so-called word characters, which include letters, digits and the underscore. The downside of this simple solution is that it allows a digit as the first character of the variable name, and the following code is possible:

```raku-static
my 4 = 3;
say 4;
```

To fix the situation, let us use the pre-defined token that matches letters:

```raku-static
token variable-name {
    [<:alpha> | '_'] \w*
}
```

Now, variable names can only start with letter or the underscore character, followed by an optional part consisting on any word characters. For example, the previous wrong program can be converted in this way:

```raku-static
my var_4 = 3;
say var_4;
```

{% include nav.html %}
