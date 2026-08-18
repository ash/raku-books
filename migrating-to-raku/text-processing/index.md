---
title: Text Processing
---

{% include menu.html %}

Text is where Perl earned its reputation, so it is reassuring that most of your
string-wrangling instincts carry straight over. `sprintf` is still `sprintf`,
`split` is still `split`, and `join` still glues a list together. What has
changed is mostly *additive*: the same jobs are now also available as methods you
can chain, a few sharp edges (character ranges, Unicode counting) have been
filed off, and a couple of new tools — `.comb`, `.trans`, `.subst` — round out
the toolkit. This chapter walks the common text operations one at a time.

## Formatted output: `sprintf` and `printf`

The two format-string workhorses need no translation at all. `printf` and
`sprintf` take the same `%`-directives you already know:

```perl
printf "%-10s|%5d\n", 'left', 42;      # left      |   42
my $s = sprintf '%05.2f', 3.14159;     # 03.14
```

```raku
printf "%-10s|%5d\n", 'left', 42;      # left      |   42
my $s = sprintf '%05.2f', 3.14159;     # 03.14
```

What Raku adds is a method form, `.fmt`, so you can format a value in the middle
of a method chain without breaking out to `sprintf`:

```raku
say 255.fmt('%04x');           # 00ff
say 3.14159.fmt('%.2f');       # 3.14
```

On a list, `.fmt` formats each element and — with an optional second argument —
joins them with a separator, which is often exactly what you want:

```raku
say (1, 2, 3).fmt('%02d', ', ');   # 01, 02, 03
say <a b c>.fmt('[%s]');           # [a] [b] [c]
```

## Splitting and joining

`split` and `join` survive with their meaning intact, but `split` gains the
sigil-free method form and a few tidier defaults. In Perl:

```perl
my @parts = split /,/, 'a,b,c';    # ('a', 'b', 'c')
my $csv   = join ',', @parts;      # a,b,c
```

In Raku, `split` takes either a string or a regex as its separator, and reads
naturally as a method. Note that a plain string separator is treated *literally*
— you do not need to quote metacharacters:

```raku
say 'a,b,c'.split(',');            # (a b c)
say 'a1b2c3'.split(/\d/);          # (a b c )   ← trailing empty piece
say 'a-b_c'.split(/<[-_]>/);       # (a b c)
```

A numeric third argument is the limit, as before:

```raku
say 'a,b,c,d'.split(',', 2);       # (a b,c,d)
```

`join` works both as a function and as a method, and the separator comes first
in the function form just as in Perl:

```raku
say join('-', 1, 2, 3);            # 1-2-3
say (1, 2, 3).join('-');           # 1-2-3
```

One habit to drop: Perl's magic `split ' '` (the single-space string that also
strips leading whitespace and splits on runs) has a clearer replacement in
`.words`, which we meet below. In Raku, `.split(' ')` splits on a single literal
space and keeps empty fields, so reach for `.words` when you mean "tokens".

## Finding and slicing: `index`, `rindex`, `substr`

`index` and `rindex` return the position of a substring, searching forwards and
backwards respectively:

```perl
my $pos = index('hello world', 'o');     # 4
my $end = rindex('hello world', 'o');    # 7
my $no  = index('hello', 'z');           # -1
```

Raku offers the same as methods. The important difference is the "not found"
result: Perl returns `-1`, but Raku returns `Nil`, which plays nicely with the
defined-or operator `//`:

```raku
say 'hello world'.index('o');      # 4
say 'hello world'.rindex('o');     # 7
say 'hello'.index('z');            # Nil
say 'hello'.index('z') // -1;      # -1   (if you really want the old sentinel)
```

`substr` reads a slice out of a string. As a method it takes a start and an
optional length, and it understands the `*-n` "from the end" form we saw in
Chapter 4:

```raku
my $s = 'Hello, World';
say $s.substr(7);          # World
say $s.substr(0, 5);       # Hello
say $s.substr(*-5);        # World   (last five characters)
```

### Read-write `substr`: `substr-rw`

In Perl, `substr` is famously an lvalue — you can assign *through* it to splice
a string in place:

```perl
my $t = 'Hello, World';
substr($t, 0, 5) = 'HELLO';    # $t is now 'HELLO, World'
```

Raku separates the two jobs. Plain `substr` is read-only, and the writable
variant is a distinct routine, `substr-rw`, which returns a container you can
assign to or bind:

```raku-nobrowser
my $t = 'Hello, World';
substr-rw($t, 0, 5) = 'HELLO';
say $t;                        # HELLO, World

my $u = 'abcdef';
my $r := $u.substr-rw(2, 2);   # bind to the slice
$r = 'XY';
say $u;                        # abXYef
```

Splitting mutable and immutable into two names means the common, read-only case
cannot surprise you by accidentally becoming an assignment target.

## `.comb` and `.words`: the inverse of split

Where `split` says "chop this string wherever the separator matches", `.comb`
says the opposite: "give me the pieces that *do* match". It is often the more
natural tool when you know what the tokens look like rather than what lies
between them:

```raku
say 'a1b2c3'.comb(/\d/);           # (1 2 3)
say '2025-07-08'.comb(/\d+/);      # (2025 07 08)
say 'hello world foo'.comb(/\w+/); # (hello world foo)
```

With no argument, `.comb` returns the individual characters (graphemes); with a
number, it returns fixed-size chunks:

```raku
say 'hello'.comb;                  # (h e l l o)
say 'abcdef'.comb(2);              # (ab cd ef)
```

`.words` is the specialised tool for whitespace-separated tokens — the honest
replacement for Perl's `split ' '`. It splits on runs of whitespace and drops
the empty edges:

```raku
say 'the  quick   brown'.words;         # (the quick brown)
say 'the quick brown'.words.elems;      # 3
```

## Translating characters: `tr///` and `.trans`

Perl's transliteration operator changes individual characters in place:

```perl
my $t = 'hello world';
$t =~ tr/a-z/A-Z/;             # HELLO WORLD
```

Raku keeps `tr///`, but binds it with the smartmatch operator `~~` rather than
`=~`, and — this catches everyone once — character ranges use `..`, not `-`:

```raku
my $t = 'hello world';
$t ~~ tr/a..z/A..Z/;
say $t;                        # HELLO WORLD
```

If you write `tr/a-z/.../` you get a compile-time error telling you to use `..`;
believe it. There is also a non-destructive `TR///` that leaves the topic alone
and *returns* the translated string:

```raku-nobrowser
$_ = 'hello';
my $v = TR/a..z/A..Z/;
say $_;                        # hello   (unchanged)
say $v;                        # HELLO
```

The result of a `tr///` numifies to the number of characters it changed, which
is handy for counting:

```raku-static
my $s = 'hello';
my $n = +($s ~~ tr/l/L/);      # 2
```

The method form is `.trans`, which is strictly more powerful than `tr///`
because it accepts full strings, not just single characters, on each side. Pass
it one or more `from => to` pairs:

```raku
say 'Hello'.trans('a..z' => 'A..Z');            # HELLO
say 'hello'.trans('el' => 'ip');                # hippo
say 'hello'.trans(['ll', 'o'] => ['LL', 'O']);  # heLLO   (multi-char keys)
```

## Substitution as a method: `.subst`

You will still write `s///` inside regex-heavy code (Chapter 18), but when you
want a substitution as an expression — something that *returns* the new string
instead of mutating in place — reach for the `.subst` method. In Perl you
would copy first, then substitute:

```perl
(my $out = $in) =~ s/the/a/g;
```

In Raku, `.subst` does it in one step and leaves the original untouched:

```raku
my $s = 'the cat sat on the mat';
say $s.subst('the', 'a');          # a cat sat on the mat   (first only)
say $s.subst('the', 'a', :g);      # a cat sat on a mat     (global)
say $s;                            # the cat sat on the mat (unchanged)
```

The replacement may be a closure, so you can transform each match:

```raku
say 'the cat sat'.subst(/\w+/, *.uc, :g);   # THE CAT SAT
```

If you *do* want in-place mutation, the sister method is `.subst-mutate`. The
`:g` (global), `:i` (ignore-case) and friends are the same adverbs `s///` takes.

## Heredocs

Perl's heredocs come in a quoted and unquoted flavour and, since 5.26, an
indented `<<~` form. Raku folds all of that into the `:to` adverb on a quote:
`q:to/END/` is non-interpolating, `qq:to/END/` interpolates, and both strip the
indentation of the closing marker from every line automatically.

```raku-static
my $name = 'Ada';

my $plain = q:to/END/;
    Plain heredoc, no $interpolation here.
    Indentation is stripped to the closing END.
    END

my $greet = qq:to/END/;
    Hello, $name!
    Two plus two is {2 + 2}.
    END
```

The `$greet` block prints:

```
Hello, Ada!
Two plus two is 4.
```

Because the closing `END` is indented four spaces, four spaces are trimmed from
the front of every line — so you can indent the heredoc to match the surrounding
code without those spaces leaking into the string. Note too that `qq` heredocs
interpolate arbitrary code in `{ }`, exactly as double-quoted strings do
(Chapter 1).

## The quoting menagerie

Perl has `q//`, `qq//`, and `qw//`. Raku keeps all three and adds `Q//` for a
completely raw string plus a set of *adverbs* that let you dial interpolation up
or down one feature at a time. The three base forms are:

```raku
my $x = 42;
say q/no $x interpolation/;        # no $x interpolation
say qq/with $x/;                   # with 42
say Q/raw: $x and \n stay literal/;# raw: $x and \n stay literal
```

`q` escapes backslashes but does not interpolate variables; `qq` interpolates;
`Q` does nothing at all — no escapes, no interpolation. Adverbs then toggle
individual behaviours. Two you will actually reach for are `:c` (interpolate
`{ }` closures only) and `:w` (split the result on words, like `qw`):

```raku
say Q:c/closure {1 + 2} only, but not $x/;     # closure 3 only, but not $x
say Q:w/one two three/;                        # (one two three)
```

The familiar `qw//` is really `Q:w//` under the hood, and Raku's angle-bracket
list `<...>` is the everyday shorthand for it:

```raku
say <foo bar baz>;                 # (foo bar baz)
```

## Unicode-aware operations

Here is the change that quietly fixes a decade of bugs. In Perl, string length
depends on whether `use utf8` is in scope and whether you are counting bytes or
characters:

```perl
say length("café");            # 5   without use utf8 (bytes)
use utf8;
say length("café");            # 4   with use utf8 (characters)
```

Raku strings are sequences of *graphemes* — what a human calls a character —
regardless of how many codepoints or bytes encode them. `.chars` counts
graphemes, always:

```raku
say "café".chars;              # 4   (even if é is e + combining accent)

my $flag = "\c[REGIONAL INDICATOR SYMBOL LETTER G]"
         ~ "\c[REGIONAL INDICATOR SYMBOL LETTER B]";
say $flag.chars;               # 1   a flag is a single grapheme…
say $flag.codes;               # 2   …built from two codepoints
```

Case-mapping is Unicode-correct too, including the tricky cases where one letter
maps to two:

```raku
say "naïve".uc;                # NAÏVE
say "STRASSE".lc;              # strasse
say "ﬁle".uc;                  # FILE   (the fi ligature expands)
```

To move between characters and their codepoint numbers, use `.ords` and `.chrs`
(the plural cousins of `ord` and `chr`):

```raku
say "ABC".ords;                # (65 66 67)
say (72, 105).chrs;            # Hi
```

When you need bytes — to write to a socket or a binary file — `.encode` turns a
string into a `Blob` of bytes, and `.decode` turns it back:

```raku
my $buf = "café".encode('UTF-8');
say $buf.bytes;                # 5   (é is two bytes in UTF-8)
say $buf.decode('UTF-8');      # café
```

Finally, normalisation. The same visible text can be stored as a single
precomposed codepoint (`é`) or as a base letter plus a combining mark
(`e` + `◌́`). This is the classic source of "these two strings look identical but
compare unequal" bugs. Raku normalises to NFC on the way in, so equality just
works, and exposes `.NFC` / `.NFD` when you need a specific form:

```raku
my $decomposed = "cafe\c[COMBINING ACUTE ACCENT]";
my $composed   = "café";
say $decomposed eq $composed;  # True   (both normalised)
say $composed.NFC.codes;       # 4      (precomposed é)
say $decomposed.NFD.codes;     # 5      (decomposed é)
```

That grapheme-by-default model is why the string operations in this chapter
"just work" on international text without a pragma or a second thought. With the
in-memory side of text handled, the next chapter turns to where text usually
comes from and goes to: files and I/O.

{% include nav.html %}
