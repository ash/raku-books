---
title: The joy of Unicode
---

{% include menu.html %}

The code here is using four characters outside of the ASCII land:

```raku
say π × $%²
```

In Raku, you can freely use the Unicode characters in identifiers, such as variable or function names. But on top of that, there are many pre-defined symbols such as π, which have ASCII alternatives. Examine the documentation page called ‘Unicode versus ASCII symbols’ to see the whole set of the Unicode characters that can be used in Raku.

Using ASCII only, the above one-liner can be re-written in the following way:

```raku-static
say pi * $r ** 2
```

Let’s return to one of the helper programs from the previous chapter and see where Unicode characters could be used:

```raku
sub f($n) {
    ($n <<*>> (1...1000 / $n)).grep: * < 1000
}

say (f(3) ∪ f(5)).keys.sum;
```

There are a few opportunities here.

First, a hyper-operator `<<*>>` can be replaced with proper French quotes: `«*»`, and the multiplication character can be a cross that we used already: `«×»`. The same can be applied to division: `÷`.

Second, the three dots of the sequence operator are replaceable with a single Unicode character: `…` (if you are programming in Word, you get this character automatically after typing the full stop three times).

Finally, in the last line, a Unicode character ∪ is used to find the intersection of two sets. The character here is the same that you use in mathematics (do you?), but you can use its ASCII version instead: `f(3) (|) f(5)`.

Unicode support is one of the best if not the best among programming languages. Use it with care not to make other people crazy about your code!

{% include nav.html %}
