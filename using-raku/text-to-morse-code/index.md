---
title: 98. Text to Morse code
---

{% include menu.html %}

*Convert the given text to the Morse code.*

Converting text to the Morse code is a relatively easy task. The solution is to replace all the alphanumeric characters with the corresponding representation in the Morse code.

In this solution, all the other characters are ignored and are removed from the source string. In the Morse code, letters are separated by the duration of one dash, and words are separated by the duration of approximately 2.5 dashes, so in the program, one space is used for separating characters, and three spaces separate the words.

The above logic is programmed in the series of replacements. First, lowercase the whole phrase (there is no distinction between lower- and uppercase letters) and then remove all the non-alphanumeric characters and increase the distance between the words. Finally, replace each remaining printable symbol with the corresponding Morse sequence.

```raku-static
my %code = (
    a => '.-',      b => '-...',    c => '-.-.',
    d => '-..',     e => '.',       f => '..-.',

    j => '.---',    k => '-.-',     l => '.-..',
    m => '--',      n => '-.',      o => '---',
    p => '.--.',    q => '--.-',    r => '.-.',
    s => '...',     t => '-',       u => '..-',
    v => '...-',    w => '.--',     x => '-..-',
    y => '-.--',    z => '--..',    0 => '-----',
    1 => '.----',   2 => '..---',   3 => '...--',

    7 => '--...',   8 => '---..',   9 => '----.'
);
my $phrase = prompt('Your phrase in plain text> ');

$phrase.=lc;
$phrase ~~ s:g/<-[a..z0..9]>/ /;
$phrase ~~ s:g/\s+/  /;
$phrase ~~ s:g/(<[a..z0..9]>)/%code{$0} /;

say $phrase;
```

Let us test this on a random phrase:

```
$ raku morse.rk
Your phrase in plain text> Hello, World!
```

The conversion table takes the biggest part of the program.

The regexes show how character classes are created.

A characters class with a range of symbols:

```
<[a..z0..9]>
```

A negative character class, which matches with any character other than the one from the range:

```
<-[a..z0..9]>
```

These character classes list all the allowed characters that can be encoded by the given `%code` hash. It is also possible to use `\w` and `\W` or `<alnum>` and `<!alnum>` instead of the above regexes if you are sure that the input string is pure ASCII.

All the regexes in the program come with the `:g` adverb to make them global. Regex matching uses the double tilde `~~` operator for both matching and replacement.

{% include nav.html %}
