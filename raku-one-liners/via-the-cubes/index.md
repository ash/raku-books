---
title: 42 via the cubes
---

{% include menu.html %}

You might have seen the formula that gives the exact value of 42, the answer of Life, the Universe and Everything. Let me reproduce it here using the power of Raku’s syntax and its arbitrary precision arithmetic, not to mention the pleasure of using superscripts directly in the code.

```
$ time raku -e'say 80435758145817515³ - 80538738812075974³ +
12602123297335631³'
```

```
real 0m0.151s
user 0m0.173s
sys 0m0.035s
```

{% include nav.html %}
