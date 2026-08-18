---
title: Appendix A — Perl to Raku Cheat Sheet
---

{% include menu.html %}

This is the whole book squeezed onto a few pages. When you know *what* you
want to do and just need the Raku spelling of it, look here first; the chapter
references in each section point you to the full story. Every entry has been run
through the compiler, but a table cannot carry the caveats — treat this as a
reminder, not a specification.

## Printing and output

| Perl | Raku | Notes |
|--------|------|-------|
| `print "hi\n";` | `print "hi\n";` | `print` is unchanged |
| `say "hi";` | `say "hi";` | `say` is on by default; no `use feature` |
| `printf "%d\n", $n;` | `printf "%d\n", $n;` | same format strings |
| `my $s = sprintf "%.2f", $x;` | `my $s = sprintf "%.2f", $x;` | identical |
| `warn "oops\n";` | `warn "oops";` | warns to `$*ERR`; resumable (Chapter 26) |
| `print STDERR "x\n";` | `note "x";` or `$*ERR.print("x\n")` | `note` adds a newline |
| `$\ = "\n";` | — | no output record separator; use `say` |
| `$, = ",";` | — | no field separator; use `.join(",")` |

## String operations

| Perl | Raku | Notes |
|--------|------|-------|
| `$a . $b` | `$a ~ $b` | the dot is now method call |
| `$s x 3` | `$s x 3` | string repetition unchanged |
| `length $s` | `$s.chars` | counts graphemes, not bytes (Chapter 7) |
| `uc $s`, `lc $s` | `$s.uc`, `$s.lc` | also `.tc` for title-case |
| `substr($s, 0, 2)` | `$s.substr(0, 2)` | function form also exists |
| `index($s, "x")` | `$s.index("x")` | returns `Nil` (not `-1`) on miss |
| `join ",", @a` | `@a.join(",")` | function form also exists |
| `split /,/, $s` | `$s.split(",")` or `.split(/,/)` | returns a `List`/`Seq` |
| `reverse $s` | `$s.flip` | `reverse` reverses lists, not strings |
| `sprintf "%s", $x` | `sprintf "%s", $x` | unchanged |

## Sigils and element access

| Perl | Raku | Notes |
|--------|------|-------|
| `$array[0]` | `@array[0]` | the sigil is invariant (Chapter 2) |
| `$hash{key}` | `%hash{'key'}` | braces need a quoted key |
| `$hash{key}` (bareword) | `%hash<key>` | `<…>` is the constant-key subscript |
| `@array[1, 2]` | `@array[1, 2]` | slice syntax unchanged |
| `@hash{qw/a b/}` | `%hash<a b>` | hash slice via angle brackets |
| `$#array` | `@array.end` | index of the last element |
| `scalar @array` | `@array.elems` | element count |
| `$array[-1]` | `@array[*-1]` | `*-1` is "one from the end" |

## Arrays

| Perl | Raku | Notes |
|--------|------|-------|
| `push @a, $x;` | `@a.push($x);` or `push @a, $x;` | both forms work |
| `pop @a;` | `@a.pop;` | |
| `shift @a;` | `@a.shift;` | |
| `unshift @a, $x;` | `@a.unshift($x);` | |
| `my @b = sort @a;` | `my @b = @a.sort;` | default sort is smart, not string-only |
| `my @b = reverse @a;` | `my @b = @a.reverse;` | |
| `grep { $_ > 2 } @a` | `@a.grep(* > 2)` | `*` is the Whatever placeholder |
| `map { $_ * 2 } @a` | `@a.map(* * 2)` | |
| `join ",", @a` | `@a.join(",")` | |
| `my @c = (@a, @b);` | `my @c = flat @a, @b;` | lists do **not** auto-flatten (Chapter 4) |
| `wantarray` | — | gone; see Appendix C |

## Hashes

| Perl | Raku | Notes |
|--------|------|-------|
| `my %h = (a => 1);` | `my %h = a => 1;` | `=>` autoquotes its left side |
| `$h{k}` | `%h<k>` / `%h{$k}` | angle brackets for constant keys |
| `keys %h` | `%h.keys` | order is not insertion order |
| `values %h` | `%h.values` | |
| `while (my ($k,$v) = each %h)` | `for %h.kv -> $k, $v {…}` | `.kv` yields key, value, key, value… |
| `exists $h{k}` | `%h<k>:exists` | `:exists` adverb |
| `delete $h{k}` | `%h<k>:delete` | `:delete` adverb |
| `%h = ()` | `%h = ()` | empties the hash |

## References and dereferencing

| Perl | Raku | Notes |
|--------|------|-------|
| `my $ref = \@a;` | `my $ref = @a;` | a scalar can just hold the array (Chapter 8) |
| `my $ref = [1, 2, 3];` | `my $ref = [1, 2, 3];` | `[…]` makes an itemised array |
| `@$ref` / `@{$ref}` | `@$ref` / `$ref[]` | |
| `$ref->[0]` | `$ref[0]` | no arrow needed |
| `$ref->{k}` | `$ref<k>` | |
| `$ref->()` | `$ref()` or `$ref.()` | |
| `\&sub` | `&sub` | `&` names a routine without calling it |
| `ref $x` | `$x.^name` / `$x.WHAT` | introspection, not a string tag |

## Control flow

| Perl | Raku | Notes |
|--------|------|-------|
| `if (...) {…}` | `if ... {…}` | parentheses optional |
| `unless (...) {…}` | `unless ... {…}` | still no `elsif` on `unless` |
| `... ? ... : ...` | `... ?? ... !! ...` | doubled punctuation |
| `while (...) {…}` | `while ... {…}` | |
| `until (...) {…}` | `until ... {…}` | |
| `for my $x (@a) {…}` | `for @a -> $x {…}` | pointy block binds the loop variable |
| `foreach (@a) {…}` | `for @a {…}` | topic is `$_` |
| `for (my $i=0;$i<10;$i++)` | `loop (my $i=0;$i<10;$i++)` | C-style loop is spelled `loop` |
| `last` / `next` / `redo` | `last` / `next` / `redo` | unchanged |
| `given/when` (feature) | `given ... { when ... {…} }` | built in (Chapter 13) |

## Subroutines and arguments

| Perl | Raku | Notes |
|--------|------|-------|
| `sub f { my ($a,$b)=@_; }` | `sub f($a, $b) {…}` | real signatures (Chapter 15) |
| `my ($a,$b?) = @_;` | `sub f($a, $b?) {…}` | `?` marks a parameter optional |
| default via `//` | `sub f($a = 42) {…}` | default value in the signature |
| slurp the rest of `@_` | `sub f(*@rest) {…}` | slurpy array |
| named args by hash | `sub f(:$name) {…}` | native named parameters |
| `$_[0] = ...` (aliasing) | `sub f($x is rw) {…}` | opt in to writable params |
| `return wantarray ? … : …` | multi dispatch / `-->` | see Chapter 16 |
| prototype dispatch | `multi sub f(...) {…}` | dispatch by arity and type |

## Regexes and substitution

| Perl | Raku | Notes |
|--------|------|-------|
| `$s =~ /pat/` | `$s ~~ /pat/` | smartmatch does the matching |
| `$s !~ /pat/` | `$s !~~ /pat/` | |
| `$s =~ s/a/b/` | `$s ~~ s/a/b/` | in-place substitution |
| `$s =~ s/a/b/g` | `$s ~~ s:g/a/b/` | `:g` is a leading adverb |
| `$s =~ s/a/b/gi` | `$s ~~ s:g:i/a/b/` | adverbs stack |
| `$s =~ tr/a-z/A-Z/` | `$s ~~ tr/a..z/A..Z/` | ranges use `..` |
| `my ($x) = /(\w+)/` | `$s ~~ /(\w+)/; say $0` | captures are `$0, $1, …` |
| `$1`, `$2` | `$0`, `$1` | captures are **0-based** (Appendix C) |
| named `(?<n>…)` / `$+{n}` | `$<n>=(…)` / `$<n>` | named captures |
| `qr/…/` | `rx/…/` or `/…/` | precompiled pattern |

## Object-oriented programming

| Perl | Raku | Notes |
|--------|------|-------|
| `package Foo;` + `bless` | `class Foo {…}` | first-class classes (Chapter 22) |
| `our @ISA = ('Bar');` | `class Foo is Bar {…}` | inheritance with `is` |
| hash-based fields | `has $.x;` / `has $!y;` | `$.` public, `$!` private |
| manual accessor subs | `has $.x;` | read accessor generated automatically |
| `has $.x is rw` | `has $.x is rw;` | writable accessor |
| `Foo->new(...)` | `Foo.new(...)` | dot, not arrow |
| `sub method { my $self = shift; }` | `method m {…}` | `self` is implicit |
| `$obj->method` | `$obj.method` | |
| `Role::Tiny` / `Moose` roles | `role R {…}` + `does R` | roles are built in (Chapter 23) |

## Modules

| Perl | Raku | Notes |
|--------|------|-------|
| `use Foo;` | `use Foo;` | |
| `require Foo;` | `require Foo;` | runtime load |
| `package Foo;` | `unit module Foo;` | or `module Foo {…}` |
| `use Exporter; @EXPORT=…` | `sub f is export {…}` | `is export` trait (Chapter 24) |
| `use parent 'Bar';` | `class Foo is Bar` | |
| CPAN + `cpan`/`cpanm` | zef + raku.land | `zef install Foo` (Chapter 25) |
| `$VERSION` | `unit module Foo:ver<1.0>;` | version in the declaration |

## Error handling

| Perl | Raku | Notes |
|--------|------|-------|
| `die "msg\n";` | `die "msg";` | throws an `X::AdHoc` exception |
| `die $object;` | `X::Custom.new(...).throw` | typed exceptions (Chapter 26) |
| `eval { … }; if ($@) {…}` | `try { … }; with $! {…}` | `$!` holds the exception |
| `eval { … } or …` | `try {…} // …` | `try` returns `Nil` on failure |
| — | `CATCH { when X::IO {…} }` | in-block typed handler |
| `$@` | `$!` | the caught exception |
| `Try::Tiny` | `try` / `CATCH` | built in |
| — | soft `Failure` objects | unthrown errors (Chapter 26) |

## Files and I/O

| Perl | Raku | Notes |
|--------|------|-------|
| `open my $fh, '<', $f` | `my $fh = open $f, :r;` | named args for the mode |
| `open my $fh, '>', $f` | `my $fh = open $f, :w;` | |
| `while (<$fh>) {…}` | `for $fh.lines {…}` | lazy line iteration |
| `my @l = <$fh>;` | `my @l = $fh.lines;` | |
| `local $/; my $c = <$fh>;` | `my $c = $f.IO.slurp;` | slurp the whole file |
| `print $fh "x";` | `$fh.print("x");` | |
| — | `spurt $f, $content;` | write a whole file at once |
| `close $fh;` | `$fh.close;` | |
| `<STDIN>` | `$*IN.lines` / `get` | Appendix C |
| `-e $f`, `-d $f` | `$f.IO.e`, `$f.IO.d` | file tests are methods |
| `chomp $line;` | `$line.chomp` | returns a new string; does not mutate |

The remaining appendices zoom in: Appendix B on operators, Appendix C on the
special variables, Appendix D on the vocabulary, and Appendix E on where to go
next.

{% include nav.html %}
