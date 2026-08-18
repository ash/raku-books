---
title: Strings
---

{% include menu.html %}

Strings are where you will feel two of Raku's big ideas at once. First, the
punctuation shifted: the concatenation dot became a tilde, because the dot now
means "call a method". Second, and more quietly, a string is no longer a flat run
of bytes or characters — it is a sequence of *graphemes*, the things a human calls
"characters", and everything that measures or slices a string counts them the way
you would. Most of your Perl string habits survive; a few operators moved, and
one deep assumption about length changed for the better.

## Concatenation: `.` becomes `~`

In Perl, you join strings with the dot, and append in place with `.=`:

```perl
my $greeting = 'Hello, ' . 'World!';
my $s = 'foo';
$s .= 'bar';              # foobar
```

In Raku the dot is reserved for method calls (Chapter 1), so concatenation is the
tilde `~`, and the in-place form is `~=`:

```raku-static
my $greeting = 'Hello, ' ~ 'World!';   # Hello, World!
my $s = 'foo';
$s ~= 'bar';                           # foobar
```

The same tilde is Raku's general "make it a string" operator: prefix `~$x` puts a
value into string context, the mirror of the numeric `+` we saw in Chapter 6.

## Repetition: `x` for strings, `xx` for lists

Perl overloads `x` to do two jobs. In scalar context it repeats a string; in
list context it repeats a list:

```perl
my $line = '-' x 10;         # ----------
my @three = (1, 2) x 2;      # (1, 2, 1, 2)
```

Raku splits these into two operators so intent is explicit. `x` always repeats a
string and returns a string; `xx` repeats a value into a list:

```raku
say '-' x 10;            # ----------
say (1, 2) xx 2;         # ((1 2) (1 2))
```

No context-guessing, no surprises: if you meant a longer string use `x`, if you
meant more list elements use `xx`.

## Length and indexing count graphemes

This is the substantive change. In Perl, `length` counts characters (or bytes,
depending on flags and how the string was decoded), and combining marks can throw
the count off. In Raku, `.chars` counts *graphemes* — user-visible characters —
so an accented letter is one character no matter how it is encoded internally:

```raku
say "café".chars;        # 4
```

The everyday measuring and slicing methods all work in graphemes. `.substr`
extracts a piece, `.flip` reverses, and `.comb` breaks a string into pieces (by
default into single characters):

```raku
say "Hello".substr(1, 3);    # ell
say "Hello".flip;            # olleH
say "Hello".comb;            # (H e l l o)
```

`.comb` also takes a pattern, which makes it the natural "pull out all the
matches" tool — the inverse of `.split`:

```raku
say "hello world".comb(/\w+/);   # (hello world)
```

Note the shape of things: `length $s` in Perl is `$s.chars` in Raku, and
`substr($s, 1, 3)` is `$s.substr(1, 3)`. The function became a method, but the
arguments are familiar.

## Case and trimming

Perl gives you `uc`, `lc`, `ucfirst`, and `lcfirst`. Raku keeps the ideas and
tidies the names. `.uc` and `.lc` are unchanged; `.tc` title-cases the first
character (Perl's `ucfirst`); `.tclc` title-cases the first character and
lower-cases the rest; and `.fc` is *case folding*, the correct way to compare
strings case-insensitively:

```raku
say "hÉLLo".uc;          # HÉLLO
say "hÉLLo".lc;          # héllo
say "hÉLLo".tc;          # HÉLLo
say "hÉLLo".tclc;        # Héllo
```

Case folding deserves a word: it is not the same as lower-casing. It maps
characters to a canonical form purpose-built for caseless matching, which is why
it handles cases lower-casing cannot:

```raku
say "STRASSE".fc eq "straße".fc;   # True
```

For whitespace, classic Perl reaches for a regex substitution, though modern Perl
now offers `builtin::trim`:

```perl
use v5.36;
use builtin 'trim';
no warnings 'experimental::builtin';

my $s = "  hi  ";
$s =~ s/^\s+|\s+$//g;      # the classic idiom
say trim("  hi  ");        # hi   (the modern builtin)
```

Raku has dedicated methods — `.trim` removes leading and trailing whitespace, and
the one-sided `.trim-leading` and `.trim-trailing` do half the job:

```raku
say "  hi  ".trim;                 # hi
say "  hi  ".trim-trailing.raku;   # "  hi"   — the leading spaces survive
```

## Searching and testing

Finding a substring works as in Perl, as methods. `.index` returns the position
of the first match and `.rindex` the last; the difference is that a miss returns
`Nil`, not `-1`:

```raku
say "hello".index("l");      # 2
say "hello".rindex("l");     # 3
say "hello".index("z");      # Nil
```

More often, though, you only want a yes-or-no answer, and for that Perl forced
the `index($s, $x) >= 0` idiom. Raku gives you three readable Boolean methods
instead:

```raku
say "hello".contains("ell");     # True
say "hello".starts-with("he");   # True
say "hello".ends-with("lo");     # True
```

## Splitting into pieces

The workhorses carry over. `.split` breaks a string on a separator, `.words`
splits on whitespace (the safe replacement for `split ' '`), and `.lines` breaks
on line boundaries:

```raku
say "a,b,c".split(",");      # (a b c)
say "a b  c".words;          # (a b c)
say "one\ntwo".lines;        # (one two)
```

Each of these returns a list of `Str`, ready to feed into `map`, `grep`, or a
`for` loop.

## Substitution as a method

Full text processing and the new regex syntax are Chapter 18 and Chapter 20; here
is just enough to replace the Perl reflex of `($x = $s) =~ s/a/b/`. Raku's
`.subst` method returns a *new* string, leaving the original untouched, and takes
a `:g` adverb for a global replace:

```raku
say "hello".subst("l", "L");         # heLlo   (first only)
say "hello".subst("l", "L", :g);     # heLLo   (all)
```

Because it returns a value rather than mutating in place, `.subst` chains cleanly
with the other methods above.

## Quotes and interpolation, recapped

Chapter 1 introduced single and double quotes, and Chapter 20 covers the full
quoting toolkit. The essentials: single quotes are literal, double quotes
interpolate. When you need a quote character *inside* the string, the `q//` and
`qq//` forms let you pick your own delimiters — `q` behaves like single quotes,
`qq` like double:

```raku-static
say q{it's a 'test'};                # it's a 'test'
say qq{double "quoted" and $greeting};
```

Interpolation in Raku goes further than Perl in two ways worth remembering.
Braces interpolate arbitrary code, not just variables:

```raku
say "Sum is { 1 + 2 + 3 }";          # Sum is 6
```

And a method call interpolates directly, as long as you include the parentheses
so Raku knows where the method ends:

```raku
my $name = "alice";
say "Upper: $name.uc()";             # Upper: ALICE
```

This is the built-in, first-class version of the Perl `@{[ ... ]}` trick we saw
in Chapter 1 — the workaround became a feature.

## Everything is an object

Notice a pattern across this chapter: `uc $s` in Perl is `$s.uc` in Raku,
`length $s` is `$s.chars`, `substr($s, ...)` is `$s.substr(...)`. Raku still
offers many of these as plain subroutines too, so `uc "hi"` also works — but the
method form is idiomatic and chains, because a string is an object like any other
(Chapter 2). Reading `$s.trim.lc.words` left to right is the everyday Raku style.

## Unicode: graphemes versus codepoints

We said `.chars` counts graphemes. It is worth seeing why that is more than a
tidy default. Take a base letter with two combining marks — a "q" with a dot
below and an acute above — which has no single precomposed codepoint:

```raku
my $g = "q\x[323]\x[301]";   # q̣́  — one grapheme, three codepoints
say $g.chars;                # 1     graphemes  (what a human sees)
say $g.codes;                # 3     codepoints (how Unicode stores it)
```

`.chars` gives the human answer, `.codes` the storage answer. When you do need
the underlying numbers, `.ords` returns the codepoint values and `.chrs` turns a
list of codepoints back into a string — the plural cousins of Perl's `ord` and
`chr`:

```raku
say "abc".ords;          # (97 98 99)
say (97, 98, 99).chrs;   # abc
```

Raku also normalises strings to a canonical form (NFC) as it creates them, so two
strings that look identical *compare* identical even if they were typed
differently. That is why a decomposed "é" (an "e" plus a combining accent) equals
a precomposed "é" without any effort on your part. When you must control the
normalisation explicitly, `.NFC` (and its siblings `.NFD`, `.NFKC`, `.NFKD`) give
you the codepoint sequence for a specific form.

## Comparing strings

The string comparison operators are unchanged from Perl: `eq`, `ne`, `lt`,
`gt`, `le`, `ge` for the yes/no tests.

```raku
say "apple" lt "banana";     # True
```

What Perl's `cmp` gave you — three-way comparison — splits into two operators in
Raku. `leg` is the pure *string* three-way compare (the direct heir of `cmp`),
while `cmp` is a smarter, type-aware comparison that will compare numbers
numerically. Both return an `Order` value — `Less`, `Same`, or `More` — rather
than the `-1`/`0`/`1` you may expect:

```raku
say "apple" leg "banana";    # Less
say "2" leg "10";            # More    (string order: "2" after "1")
say 2 cmp 10;                # Less    (cmp knows these are numbers)
```

For sorting text you want `leg`; for sorting a mixed or numeric list you usually
want `cmp`, and Chapter 27 returns to both when we look at custom sort routines.

With scalars, numbers, and strings behind us, the next chapter steps back to the
machinery underneath them all — how Raku replaced Perl's references with
*containers*, and how that reshapes context.

{% include nav.html %}
