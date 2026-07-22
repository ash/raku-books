---
title: Unicode
---

{% include menu.html %}

The strings in Perl 6 are internally handled in the format called NFG (Normalization Form Grapheme). From a practical point of view, that means that, for any symbol, you can get its NFC, NFD, NFKC and KFKD forms. I will refer you to read about the details of these formats to the Unicode standard. In simple words, these are different canonical and decomposed forms of a symbol.

There are four methods with those names, and you may call them on character strings:

```raku-static
say $s.NFC; # codepoint
say $s.NFD;
say $s.NFKC;
say $s.NFKD;
```

The full canonical name of a character is returned by the method `uniname`:

```
say 'λ'.uniname; # GREEK SMALL LETTER LAMDA
```

In the string class, the `encode` method is defined; it helps to see how the string is built internally in one of the Unicode charsets:

```raku-nobrowser
my $name = 'naïve';
say $name.encode('UTF-8');  # utf8:0x<6e 61 c3 af 76 65>
say $name.encode('UTF-16'); # utf16:0x<6e 61 ef 76 65>
```

As an exercise, examine the output for the following characters. The `unidump` function, shown below, prints some characteristics of the Unicode characters.

```raku-nobrowser
unidump('☭');
unidump('ы');
unidump('å');
unidump('é');
unidump('ϔ');
# One of the few characters, for which all the four
# canonical forms are different.

unidump('й');
unidump('²');
unidump('Æ');

sub unidump($s) {
    say $s;
    say $s.chars; # number of graphemes
    say $s.NFC;   # code point
    say $s.NFD;
    say $s.NFKC;
    say $s.NFKD;
    say $s.uniname; # the Unicode name of the character
    say $s.uniprop; # the Unicode properties of the first grapheme
    say $s.NFD.list; # as a list
    say $s.encode('UTF-8').elems; # number of bytes
    say $s.encode('UTF-16').elems;
    say $s.encode('UTF-8'); # as utf8:0x<...>
    say '';
}
```

The NFKC and NFKD forms, in particular, transform the sub- and superscript to regular digits.

```raku-nobrowser
say '2'.NFKD; # NFKD:0x<0032>
say '²'.NFKD; # NFKD:0x<0032>
```

The `unimatch` function indicates whether a character belongs to one of the Unicode character groups.

```raku
say unimatch('道', 'CJK'); # True
```

Be warned, because some characters can look the same but are in fact different characters in different parts of the Unicode table.

```raku
say unimatch('ї', 'Cyrillic'); # True
say unimatch('ï', 'Cyrillic'); # False
```

The characters in the example are `CYRILLIC SMALL LETTER YI` and `LATIN SMALL LETTER I WITH DIAERESIS`, respectively; their NFD representations are `0x<0456 0308>` and `0x<0069 0308>`.

It is also possible to check the Unicode properties using regexes:

```raku
say 1 if 'э' ~~ /<:Cyrillic>/;
say 1 if 'э' ~~ /<:Ll>/; # Letter lowercase
```

Use the `uniprop` method to get the properties:

```raku
say "x".uniprop; # Ll
```

To create a Unicode string directly, you may use the constructor of the Uni class:

```raku
say Uni.new(0x0439).Str;     # й
say Uni.new(0xcf, 0x94).Str; # Ï
```

Also, you can embed copepoints in the string:

```raku
say "\x0439";   # й
say "\xcf\x94"; # Ï
```

{% include nav.html %}
