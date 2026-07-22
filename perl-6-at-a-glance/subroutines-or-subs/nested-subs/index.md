---
title: Nested subs
---

{% include menu.html %}

Nested subs are allowed in Perl 6.

```raku
sub cube($x) {
    sub square($x) {
        return $x * $x;
    }

    return $x * square($x);
}

say cube(3); # 27
```

The name of the inner sub `square` is only visible within the body of the outer sub `cube`.

{% include nav.html %}
