---
title: 99. Morse to text
---

{% include menu.html %}

*Convert the Morse sequence to plain text.*

To save efforts in typing the decoding table, we can use the `%code` hash from Task 98, Text to Morse code, and create the ‘inversed’ hash, where the keys are the Morse sequences, and the values are letters or digits:

```raku-static
my %char = %code.kv.reverse;
```

Printing this variable shows its contents in the following way:

```
{- => t, -- => m, --- => o, ----- => 0, ----. => 9, ---.. => 8,
--. => g, --.- => q, --.. => z, --... => 7, -. => n, -.- => k,

. => e, .- => a, .-- => w, .--- => j, .---- => 1, .--. => p,
.-. => r, .-.. => l, .. => i, ..- => u, ..--- => 2, ..-. => f,
```

Despite the fact that the output does not include the quotes, all the keys and values in `%char` are strings. The next step is to replace the sequences from the keys of the hash with its values. The small difficulty is that, unlike the text-to-Morse conversion, a regex has to search for the sequence of a few characters (dots and dashes), so it must anchor to the boundaries of the Morse characters.

The built-in `<<` and `>>` regex anchors for word boundaries assume that the words are sequences of letters and digits, while Morse sequences are dots and dashes. Let’s use a space to serve as a separating character. To simplify the task, just add an additional space to the string before decoding it.

```raku-static
my $text = prompt('Morse phrase> ') ~ ' ';
$text ~~ s:g/(<[.-]>+) ' '/%char{$0}/;
$text ~~ s:g/\s+/ /;
say $text;
```

{% include nav.html %}
