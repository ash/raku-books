---
title: 3. String length
---

{% include menu.html %}

*Print the length of a string.*

The Raku language handles all strings as UTF-8 by default. This is why there is more than one parameter describing the length of the string. In fact, the `length` routine does not exist, and an attempt to use it issues an error message with some hints to which other methods you can use.

To get the length of the string in the sense of number of characters, use the `chars` method:

```raku
say 'hello'.chars;  # 5
say 'café'.chars;   # 4
say 'привет'.chars; # 6
```

The results reflect the intuitive expectation and do not depend on actual representation of the characters. The first string fits in the ASCII table, the second may still be encoded in an 8-bit encoding Latin-1, and the third needs two bytes per character in the UTF-8 encoding.

Another method, `codes`, returns the number of codepoints in the Unicode space. For the above examples, both `chars` and `codes` return the same numbers, as all the characters can be represented by a single codepoint.

```raku
say 'hello'.codes;  # 5
say 'café'.codes;   # 4
say 'привет'.codes; # 6
```

Although, when using combining characters, you may create a character that does not exist as a separate character in the Unicode table. In this case, the results of `chars` and `codes` may differ.

Consider an example with a character built out of two elements: Latin letter `x` and a combining character `COMBINING OGONEK`. Together, they form a nonexisting letter, which is one character, but two codepoints:

```raku
say 'x'.chars; # 1
say 'x'.codes; # 2
```

Let us dig a bit into how the above character is represented in the UTF-8 encoding. It consists of two parts: `LATIN SMALL LETTER X` and the combining character `COMBINING OGONEK`. The letter itself is a one-byte code `0x78`, and the combining character has the Unicode entry point `0x328` and needs two bytes in UTF-8: `0xCC 0xA8`.

Let us rewrite the example by explicitly specifying the codepoint of the combining character:

```raku
say "x\x[0328]".chars; # 1
say "x\x[0328]".codes; # 2
```

The above example was about the character that does not exist in Unicode as a single codepoint. Now, let us use another letter, say `e`, which forms an existing character with the same combining character: `ę`.

```raku
say 'ę'.chars; # 1
say 'ę'.codes; # 1
```

In this case, both `chars` and `codes` methods return 1. Even if the string is built using an explicit combining character, the `codes` method coerces it back to the proper codepoint and does not count it as a separate code:

```raku
say "e\x[0328]".chars; # 1
say "e\x[0328]".codes; # 1
```

Thus, in many cases, to get the length of a string, it is enough to use the `chars` method called on that string.

{% include nav.html %}
