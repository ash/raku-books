---
title: Negation
---

{% include menu.html %}

The negating exclamation mark `!` is used to create the next set of meta-operators. If it is prepended to the existing operator `op`, you get the operator that gives you the negated result `!op`.

```raku
say "no" if "abcd" !~~ "e";
```

{% include nav.html %}
