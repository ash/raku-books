---
title: Numbers
---

{% include menu.html %}

Creating numbers in different formats:

```raku-static
my int = 42;
say int; ## 42

my float = 3.14;
say float; ## 3.14

my sci = 3E14;
say sci; ## 300000000000000

my negative = -1.2;
say negative; ## -1.2

my zero = 0;
say zero; ## 0

my half = .5;
say half; ## 0.5

my minus_n = -.3;
say minus_n; ## -0.3
```

Notice that the floating-point numbers without the integer part are printed with a zero before the decimal point, and thus you should expect for example, `0.5`, not `.5`.

{% include nav.html %}
