---
title: Cross-operators
---

{% include menu.html %}

The cross meta-operator prefix, `X`, applies an operation to all the possible combinations of the elements of the operands that are treated in list context. The result of the cross-operation is also a list.

Here is an example that prints the coordinates for all the cells of a chess board:

```raku
say 'a'..'h' X~ 1..8;
```

{% include nav.html %}
