---
title: |, &, ^
---

{% include menu.html %}

`|`, `&`, and `^` create the so-called junctions (formerly known in Perl 6 as quantum superpositions). These objects can be used where a scalar is used but behave differently; unlike the scalars, the junctions have multiple values at the same moment in time.

The `|`, `&`, and `^` operators create, respectively, the junctions of the `any`, `all`, and `one` types.

```raku
# The value of 4 is one of the listed options
say "ok" if 4 == 1|2|3|4|5;

# There is no 4 in the list
say "ok" if 4 != 1 & 2 & 3 & 5;

# 4 repeats twice, thus it is not unique
say "ok" unless 4 == 1 ^ 2 ^ 2 ^ 4 ^ 4 ^ 5;
```

{% include nav.html %}
