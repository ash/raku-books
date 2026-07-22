---
title: Arrays and hashes
---

{% include menu.html %}

Aggregate data types are very important for the language, let us test them too. First, trivial test cases for creating and printing arrays:

```raku-static
my a[];
a = 3, 4, 5;
say a; ## 3, 4, 5

my b[] = 7, 8, 9;
say b; ## 7, 8, 9
```

And hashes:

```raku-static
my h{};
say h; ## 

my g{} = "a": "b", "c": "d";
say g; ## a: b, c: d
```

Then try using variables as array indices or hash keys:

```raku-static
my a[] = 2, 4, 6, 8, 10;
my i = 3;
say a[i]; ## 8

my b{} = "a": 1, "b": 2;
my j = "b";
say b{j}; ## 2
```

This test works fine.

{% include nav.html %}
