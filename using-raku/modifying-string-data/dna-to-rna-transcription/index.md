---
title: 10. DNA-to-RNA transcription
---

{% include menu.html %}

*Convert the given DNA sequence to a compliment RNA.*

We’ll not dig deep into the biology aspect of the problem. For us, it is important that the DNA is a string containing the four letters A, C, G, and T, and the RNA is a string of A, C, G, and U. The transformation from DNA to RNA happens according to the following table:

DNA

```
A
C
G
T
```

RNA

```
U
G
C
A
```

In the `Str` class, the `trans` method is defined; it takes pairs ‘old character— new character’. So, to translate from DNA to RNA, let’s write the above table as a hash and use it with the `trans` method:

```raku-nobrowser
my %transcription =
    A => 'U', C => 'G', G => 'C', T => 'A';

my $dna = 'ACCATCAGTC';
my $rna = $dna.trans(%transcription);
say $rna; # UGGUAGUCAG
```

The `trans` method accepts a few attributes that alternate its behaviour. For example, the `:squash` attribute removes the duplicated characters. This probably does not make sense in biology, but works for us an exercise:

```raku-static
say $dna.trans(%transcription, :squash); # UGUAGUCAG
```

It is also possible to replace the sequences of more than one character. For example:

```raku-static
say $dna.trans('ACCA' => 'UGGU', 'TCA' => 'AGU',
               'GTC' => 'CAG');
```

{% include nav.html %}
