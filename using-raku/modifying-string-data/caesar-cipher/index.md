---
title: 11. Caesar cipher
---

{% include menu.html %}

*Encode a message using the Caesar cipher technique.*

The Caesar code is a simple method of transcoding the letters of the message so that each letter is replaced with the letter that occurs in the alphabet N positions earlier or later.

For example, if N is 4, then the letter e becomes a, f is transformed to b, etc. The alphabet is looped so that z becomes v, and letters a to d become w to z.

The `Str` data type is equipped with the `trans` method, which we have seen in Task 10, DNA-to-RNA transcription. It is also quite easy to use ranges in the replacement recipe:

```raku
my $message = 'hello, world!';

my $secret = $message.trans(
                 ['a' .. 'z'] =>
                 ['w' .. 'z', 'a' .. 'v']
             );
say $secret; # dahhk, sknhz!
```

You can read the original message by translating it back with the same method but with swapped arrays:

```raku-static
say $secret.trans(
    ['w' .. 'z', 'a' .. 'v'] =>
    ['a' .. 'z']
);
```

Try modifying the solution so that it also works with the strings containing capital letters.

{% include nav.html %}
