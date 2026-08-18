---
title: Regexes Reworked
---

{% include menu.html %}

Here it is — the largest single break from Perl in the whole language. Take a
breath: nothing you know about regular expressions is *wrong*, but a good deal of
the punctuation has moved, and a few defaults have been flipped on purpose. The
payoff is enormous. Raku's regexes are readable, composable, and they grow
smoothly into full grammars (Chapter 19). This chapter is deliberately thorough,
because once these foundations click, the rest is a pleasure.

The single most important thing to internalise up front: **in a Raku regex,
whitespace is not significant by default.** It is as if Perl's `/x` modifier
were always switched on. That one change explains most of the surface differences
you are about to see.

## Whitespace no longer matches whitespace

In Perl, a space in a pattern matches a space in the string:

```perl
"the cat sat" =~ / cat /;      # matches " cat "
```

In Raku, the spaces are just there to help *you* read the pattern. They match
nothing. So you can pad a pattern out for clarity and it means the same thing:

```raku
say "the cat sat" ~~ / cat /;      # ｢cat｣  — the spaces are ignored
```

Because spaces are free, you write a literal string by *quoting* it. Single or
double quotes both work, and a quoted string matches exactly, spaces and all:

```raku
say "the cat sat" ~~ / "cat sat" /;   # ｢cat sat｣
```

A single unquoted alphanumeric run is still a literal, so `/ cat /` finds `cat`.
But the moment you put spaces *between* letters, Raku assumes you meant them as
separators and warns you:

```raku
say "the cat sat" ~~ / c a t /;
# Space is not significant here; please use quotes or :s ...
```

The fix is to quote the literal (`/ "cat" /`) or to turn significant whitespace
back on with the `:s` adverb, covered below. This feels alien for about a day,
then you never want to go back — patterns stop being a wall of backslashes.

## Matching: `~~`, `m/.../`, and `.match`

Perl binds a pattern to a string with `=~`:

```perl
if ($str =~ /(\d+)/) { print "found $1\n" }
```

Raku uses the smartmatch operator `~~`, and the capture is in `$0`, not `$1`
(more on numbering shortly):

```raku
if "abc123" ~~ m/(\d+)/ { say "found $0" }    # found 123
```

The bare `/.../` form is a regex literal, and `m/.../` is the matching form; in a
smartmatch they behave the same. There is also a method, `.match`, which is handy
in a chain and takes the same adverbs as named arguments:

```raku
my $m = "hello world".match(/(\w+) \s (\w+)/);
say $m.Str;  # hello world
say $0;      # ｢hello｣
say $1;      # ｢world｣
```

Notice `\s` there: the *predefined* character classes like `\d`, `\w`, and `\s`
survive unchanged and are the idiomatic way to match "some whitespace" now that a
plain space matches nothing.

## The `$/` Match object and its captures

Every match populates the special variable `$/`, the *Match object*. This is the
Raku descendant of Perl's `$&`, `$1`, `%+` and friends, all folded into one
tidy object. It stringifies to the matched text and carries the captures inside
it:

```raku
if "abcdef" ~~ /cd/ {
    say $/.Str;        # cd
    say $/.prematch;   # ab
    say $/.postmatch;  # ef
}
```

Positional captures live at `$0`, `$1`, `$2` … — these are simply shortcuts for
`$/[0]`, `$/[1]`, and so on. Raku counts capturing groups **from zero**, which is
the change most likely to catch a Perl reflex:

```raku
if "2026-07-09" ~~ /(\d+)\-(\d+)\-(\d+)/ {
    say "$0 $1 $2";    # 2026 07 09
}
```

Named captures use a different, clearer syntax. Instead of `(?<name>...)`, you
write `$<name>=(...)`, and you read the result as `$<name>` (short for
`$/<name>`):

```raku
if "John Smith" ~~ / $<first>=(\w+) \s $<last>=(\w+) / {
    say $<first>;     # ｢John｣
    say $<last>;      # ｢Smith｣
    say $/<last>;     # ｢Smith｣  — the long form
}
```

## Character classes

A bracketed character class in Perl is `[...]`. In Raku the enumerated class
gets an angle-bracket wrapper so that `[...]` can be reused for grouping (it is
Raku's non-capturing group). A positive class is `<[...]>`, a negated one is
`<-[...]>`, and ranges use `..`:

```raku
say "hello" ~~ /<[a..z]>+/;      # ｢hello｣
say "hello5" ~~ /<-[a..z]>/;     # ｢5｣    — first non-lowercase char
say "abc" ~~ /<[a..c d e]>+/;    # ｢abc｣  — spaces inside are just separators
```

Alongside the backslash classes, Raku offers a family of *named* character
classes you call like subrules: `<digit>`, `<alpha>`, `<alnum>`, `<space>`,
`<upper>`, `<lower>`, and the composite `<ident>` (a valid identifier) and
`<ws>` (whitespace, used everywhere internally):

```raku
say ("abc123" ~~ /<digit>+/).Str;      # 123
say ("foo_bar123" ~~ /^<ident>$/).Str; # foo_bar123
```

One surprise worth flagging: `<alpha>` matches the underscore as well as
letters, because it follows the identifier convention. If you want letters only,
spell out `<[a..z A..Z]>`.

## Quantifiers and separators

The old quantifiers `*`, `+`, and `?` are unchanged. What replaces the clumsy
`{2,4}` is a spelled-out operator, `**`, which reads almost like English:

```raku
say "aaa"  ~~ /a ** 2/;       # ｢aa｣    — exactly two
say "aaaa" ~~ /a ** 2..3/;    # ｢aaa｣   — a range, two to three
```

The genuinely new tool is the *separator* quantifier. Matching a list of things
separated by commas is such a common chore that Raku builds it in with `%`:

```raku
say "1,2,3"  ~~ /\d+ % ","/;    # ｢1,2,3｣   — items separated by commas
say "1,2,3," ~~ /\d+ %% ","/;   # ｢1,2,3,｣  — %% also allows a trailing one
```

`%` means "separated by"; `%%` means "separated or terminated by". No more
writing `\d+ (?: , \d+ )*` by hand.

## Alternation: `|` versus `||`

Perl's `|` tries the branches left to right and takes the first that matches.
Raku splits that into two operators. The double `||` keeps the old *ordered*
behaviour:

```raku
say "foobar" ~~ / foo || foobar /;   # ｢foo｣  — first branch wins
```

The single `|` is new: it uses **longest-token matching**, picking whichever
branch matches the most text regardless of order — the same rule Raku's own
grammar engine uses:

```raku
say "foobar" ~~ / foo | foobar /;    # ｢foobar｣  — longest wins
```

When in doubt, `||` behaves like the Perl `|` you already know.

## Anchors

The workhorses carry over, and a couple are added. `^` and `$` anchor to the
start and end of the *string*; `^^` and `$$` anchor to the start and end of a
*line* (the counterparts of Perl's `/m` behaviour, but always available). Word
boundaries, once the cryptic `\b`, become the readable `<<` and `>>`:

```raku
say "cat"     ~~ /^ cat $/;        # ｢cat｣
say "the cat" ~~ / << cat >> /;    # ｢cat｣  — left and right word boundaries
```

## Adverbs (the modifiers)

Modifiers move from trailing letters to *adverbs* written after the `m` or `s`,
each introduced by a colon. The common ones:

```raku
say "HELLO"  ~~ m:i/hello/;         # ｢HELLO｣          — :i, case-insensitive
say "a1b2c3" ~~ m:g/\d/;            # (｢1｣ ｢2｣ ｢3｣)    — :g, global, returns a list
say "the cat sat" ~~ m:s/the cat/;  # ｢the cat｣    — :s, spaces are significant
```

`:s` (or its long name `:sigspace`) is how you opt back in to Perl's rule that
spaces in the pattern match runs of whitespace in the text — useful for
free-form input. Two more you will meet: `:ratchet`, which switches off
backtracking (the match never gives characters back once it has taken them), and
`:ex` (`:exhaustive`), which finds every possible match, including overlapping
ones:

```raku
say ("aaa" ~~ m:ex/a+/).elems;  # 6   — every match, overlaps included
```

Ratcheting matters more than it first appears, and Chapter 19 leans on it
heavily.

## Substitution

Perl's `s///` becomes Raku's `s///`, and it still modifies the variable in
place through `~~`. The `/g` flag becomes the `:g` adverb:

```raku-static
my $s = "hello world";
$s ~~ s/world/Raku/;        # $s is now "hello Raku"
my $t = "a-b-c";
$t ~~ s:g/\-/_/;            # $t is now "a_b_c"
```

If you want a *copy* rather than an in-place edit, the capital `S///` returns the
transformed string and leaves the original alone:

```raku-static
my $orig = "hello";
my $new  = S/l/L/ given $orig;   # $new is "heLlo", $orig untouched
```

And because everything is an object (Chapter 2), there is a method form,
`.subst`, which takes a plain string or a regex and the usual adverbs as named
arguments:

```raku
say "hello world".subst("world", "Raku");   # hello Raku
say "aXbXc".subst(/X/, "-", :g);            # a-b-c
```

## Lookahead assertions

Zero-width lookahead loses its `(?=...)` and `(?!...)` spelling in favour of the
readable `<?before ...>` and `<!before ...>`:

```raku
say "foobar" ~~ / foo <?before bar> /;   # ｢foo｣  — foo, only if bar follows
say "foobaz" ~~ / foo <!before bar> /;   # ｢foo｣  — foo, only if bar does NOT
```

(There are `<?after>` and `<!after>` for lookbehind, too.)

## Naming pieces: `regex`, `token`, and `rule`

Here is where Raku pulls decisively ahead. You can name a pattern and reuse it,
exactly as you name a subroutine. Declare it with `my regex`, then call it inside
another pattern by its name in angle brackets:

```raku
my regex word { \w+ }
my $m = "hello" ~~ /<word>/;
say $m.Str;                 # hello
say $<word>;                # ｢hello｣  — the subrule captures under its name
```

There are two specialised cousins. A `token` is a regex with `:ratchet` built in
(no backtracking), and a `rule` is a `token` with `:sigspace` built in as well.
The ratchet difference is real and worth seeing:

```raku
my regex r { \d+ 5 }
say ("12345" ~~ /<r>/).Str;   # 12345  — backtracks: \d+ gives back the 5

my token t { \d+ 5 }
say "12345" ~~ /<t>/;         # Nil    — no backtrack: \d+ ate the 5, match fails
```

For most parsing work you want `token` (fast, predictable) or `rule` (when
whitespace between pieces matters). These three declarators are the whole bridge
to grammars.

## Interpolating a variable: literal versus regex

A subtle but important distinction. Interpolating a scalar with `$var` inserts
its contents as a **literal** string — metacharacters lose their power:

```raku
my $var = "c.t";
say "cat" ~~ /$var/;    # Nil          — the dot is a literal dot
say "c.t" ~~ /$var/;    # ｢c.t｣        — matches the literal text
```

To interpolate a variable's contents as an actual **regex**, wrap it as an
assertion with `<$var>`:

```raku
my $pat = "c.t";
say "cat" ~~ /<$pat>/;  # ｢cat｣        — now the dot matches any character
```

This is the safe default Perl never had: user input dropped into `/$var/`
cannot accidentally inject metacharacters, because it is treated as plain text
unless you deliberately ask otherwise.

Named tokens that call each other, longest-token alternation, ratcheting by
default — you have quietly assembled every ingredient of a grammar. In the next
chapter we gather these named pieces under a single `grammar` keyword and let
them parse structured text into a tree.

{% include nav.html %}
