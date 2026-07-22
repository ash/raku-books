---
title: Strings
---

{% include menu.html %}

For strings, let us first test simple initialisation and assignment:

```raku-static
my s1;
s1 = "Hello, World!";
say s1; ## Hello, World!

my s2 = "Another string";
say s2; ## Another string

my s3 = ""; # Empty string
say s3; ##
```

In a separate file, let us test string interpolation:

```raku-static
my i = 10;
my f = -1.2;
my c = 1E-2;
my s = "word";

my str = "i=$i, f=$f, c=$c, s=$s";
say str; ## i=10, f=-1.2, c=0.01, s=word
```

We also allow three characters to be escaped:

```raku
say "\\"; ## \
say "\\\\"; ## \\
say "\$"; ## $
say "\""; ## "
```

{% include nav.html %}
