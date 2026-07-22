---
title: Built-in functions
---

{% include menu.html %}

Throughout the book, we were using the `say` function, that is a perfect example of a built-in function. In this section, we’ll implement three more functions: `print`, `len`, and `keys`. Of course, you may extend the list with your own interesting functions later.

Allow the new keyword in the grammar:

```raku-static
token function-name {
    'say' | 'print' | 'len' | 'keys'
}
```

{% include nav.html %}
