---
title: Generating random passwords
---

{% include menu.html %}

Here’s the full code addressing the problem:

```raku
('0'..'z').pick(15).join.say
```

Run it a few times:

```raku-static
Z4x72B8wkWHo0QD
J;V?=CE84jIS^r9
2;m6>kdHRS04XEL
O6wK=umZ]DqyHT5
3SP\tNkX5Zh@1C4
PX6QC?KdWYyzNOc
bq1EfBZNdK9vHxz
```

Our line of code generates different strings each time you run it. Try it yourself to create a password or take one of the above-shown passwords if you did not install Raku yet.

*You may also ask a question: What characters can I expect in the password?*

Great that you ask! Raku is a Unicode-oriented language, and the range `'0'..'z'` seems to contain characters with different Unicode properties (i. e., digits and letters at least). To see what’s inside, just remove the `pick` method from our one-liner:

```raku
('0'..'z').join.say
```

This line prints the subset of the ASCII table between the two given characters:

```raku-static
0123456789:;<=>?@
ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`
abcdefghijklmnopqrstuvwxyz
```

These are the characters that may appear in the password. The `pick` method makes sure characters are not repeated. If you use `roll` instead, then you allow the characters to appear more than once.

{% include nav.html %}
