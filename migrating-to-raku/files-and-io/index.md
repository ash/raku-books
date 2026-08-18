---
title: Files and I/O
---

{% include menu.html %}

The Perl file-handling ritual is muscle memory by now:

```perl
open(my $fh, '<', $file) or die "Cannot open $file: $!";
while (my $line = <$fh>) {
    chomp $line;
    say uc $line;
}
close $fh;
```

Raku can do all of this, and the three-argument `open` even survives in spirit.
But most of the time you will not open a handle at all. Raku puts the common
operations — read the whole file, read it line by line, write a string out —
directly on the *path*, so the boilerplate above collapses to a single
expression. This chapter starts from the path-centric style you will use daily,
then drops down to explicit handles for the cases that need them.

## The path is the object: `IO::Path`

In Raku, a filename becomes a first-class object by calling `.IO` on the string.
That gives you an `IO::Path`, and every file operation hangs off it. The whole
Perl loop above becomes:

```raku-static
for $file.IO.lines -> $line {
    say $line.uc;
}
```

Two things vanished. There is no `open` and no `close` — `.lines` opens the file,
hands you the lines lazily, and closes it when the sequence is exhausted. And
there is no `chomp`: **`.lines` strips the line terminator for you**, so `$line`
never carries a trailing newline. That single default removes one of the most
forgotten steps in Perl.

## Reading a whole file: `.slurp`, `.lines`, `.words`, `.comb`

The examples that follow read a small `data.txt` — three lines, six words:

```
alpha beta
gamma delta
epsilon zeta
```

For the "give me everything" cases, the methods read like plain English:

```raku-local
my $text  = 'data.txt'.IO.slurp;      # the whole file as one string
my @lines = 'data.txt'.IO.lines;      # a list of chomped lines
my @words = 'data.txt'.IO.words;      # whitespace-separated tokens
```

`.slurp` is the counterpart of Perl's `local $/; <$fh>` trick, but without the
incantation. `.lines` and `.words` are the streaming readers. And because a path
is just an object, the text methods from Chapter 20 apply directly — `.comb`, for
instance, pulls matching pieces straight out of a file:

```raku-local
say 'data.txt'.IO.lines.elems;        # 3
say 'data.txt'.IO.comb(/\w+/).elems;  # 6   (all the words, by regex)
```

The crucial property of `.lines` is that it is **lazy**. It does not read the
file into memory; it yields lines one at a time as you consume them. That is why
the same method serves both a tiny config file and a multi-gigabyte log:

```raku-local
# Never loads the whole file — safe on huge inputs.
for 'huge.log'.IO.lines -> $line {
    .say if $line.contains('ERROR') given $line;
}
```

Assigning to a `my @array`, as in `my @lines = ....lines`, *does* pull everything
into memory, because the array has to be filled. Keep the result in the `for`
loop (or use `.grep`/`.map`) when the file is large, and reify it into an array
only when it is small enough to hold.

## Writing a whole file: `.spurt`

The mirror image of `.slurp` is `.spurt`, which writes a string (or a `Blob`) to
a file, creating or truncating it. It replaces the open-print-close dance
entirely:

```raku-local
spurt 'out.txt', "line one\nline two\n";
'out.txt'.IO.spurt("via method\n");        # method form
spurt 'out.txt', "appended\n", :append;    # add instead of overwrite
```

Both `spurt` and `slurp` exist as a bare subroutine and as a method on
`IO::Path`; use whichever reads better in context.

## File tests and path parts

Perl's file-test operators (`-e`, `-f`, `-d`, `-r`, `-s`) become methods on the
path. The letters are the same, so the translation is nearly mechanical:

```perl
if (-e $file && -f $file) { ... }
my $size = -s $file;
```

```raku-local
my $p = 'data.txt'.IO;
say $p.e;          # True   — exists          (-e)
say $p.f;          # True   — is a plain file  (-f)
say $p.d;          # False  — is a directory   (-d)
say $p.r;          # True   — is readable      (-r)
say $p.s;          # 36     — size in bytes     (-s)
```

The modification time comes back as an `Instant`, which you can turn into a
`DateTime` for display:

```raku-static
say $p.modified.DateTime;      # 2026-07-08T...Z
```

Splitting a path into pieces no longer needs `File::Basename`; the methods are
built in:

```raku-local
my $f = '/home/ash/notes.txt'.IO;
say $f.basename;                     # notes.txt
say $f.extension;                    # txt
say $f.parent;                       # "/home/ash".IO
say 'archive.tar.gz'.IO.extension;   # gz
```

## Directories and file management

Listing a directory, making one, and moving files around are all plain routines.
In Perl you would `opendir`/`readdir`/`closedir`; in Raku, `dir` returns a lazy
list of `IO::Path` objects:

```raku-local
mkdir 'sub';
'sub/a.txt'.IO.spurt("hello\n");
'sub/b.raku'.IO.spurt("say 42\n");

say dir('sub').sort;                    # ("sub/a.txt".IO "sub/b.raku".IO)
say dir('sub', test => /'.txt' $/);     # ("sub/a.txt".IO) — only the .txt files
```

The `test` named argument filters the entries with a smartmatch, so a regex, a
string, or any matcher works. The remaining housekeeping routines mirror their
Perl namesakes:

```raku-local
copy   'sub/a.txt', 'sub/c.txt';   # like File::Copy's copy
rename 'sub/c.txt', 'sub/d.txt';   # rename / move
unlink 'sub/d.txt';                # delete
say 'sub/d.txt'.IO.e;              # False — it is gone
```

## Explicit handles with `open`

When you need to keep a handle open — interleaving reads and writes, or holding a
file across several operations — `open` gives you an `IO::Handle`. The mode is a
named adverb rather than a string: `:r` to read, `:w` to write (truncating),
`:a` to append.

```raku-static
my $fh = open 'data.txt', :r;
say $fh.get;             # alpha beta   — .get reads one chomped line
say $fh.lines.elems;     # 2            — .lines reads the rest, lazily
$fh.close;
```

Note how error handling changed. Perl leans on `open(...) or die "...: $!"`.
In Raku, a failed `open` returns a `Failure` — a lazy, unthrown exception
(Chapter 26). You can still write `or die`, but you rarely need to: if you simply
*use* the handle, the `Failure` throws itself with a full, helpful message:

```raku-static
my $fh = open 'nope.txt', :r;   # returns a Failure
$fh.get;                        # throws here:
# Failed to open file .../nope.txt: No such file or directory
```

So the `or die` guard becomes optional rather than obligatory. When you do want
to react rather than crash, wrap it in a `try`/`CATCH`, which Chapter 26 covers
in full.

### Writing through a handle

`print`, `put`, and `say` all exist as methods on a handle. Choose by how you
want the value rendered and whether you want a trailing newline:

```raku-static
my $out = open 'out.txt', :w;
$out.say('written with say');    # adds a newline, uses .gist
$out.print("no newline");        # no newline
$out.put('put adds a newline');  # adds a newline, uses .Str
$out.close;
```

The `put` routine is the one most like Perl's `say`: it appends a newline but
stringifies with `.Str` rather than the display-oriented `.gist`. The difference
shows on lists — `say (1,2,3)` prints `(1 2 3)`, whereas `put (1,2,3)` prints
`1 2 3`. Always `close` a handle you opened for writing, so buffered output is
flushed.

## Standard handles: `$*IN`, `$*OUT`, `$*ERR`

Perl's `STDIN`, `STDOUT`, and `STDERR` become the dynamic variables `$*IN`,
`$*OUT`, and `$*ERR` — the `$*` twigil we met in Chapter 3. They are ordinary
`IO::Handle`s, so the same methods apply:

```raku
$*OUT.say('to standard output');
$*ERR.say('to standard error');

for $*IN.lines -> $line {         # read stdin, line by line, chomped
    say $line.tc;
}
```

Because they are *dynamic* variables rather than global barewords, you can
temporarily rebind them for a scope — redirecting output without touching the
rest of the program — which the special-variables appendix (Appendix C) revisits.
Plain `say`, `put`, and `print` without a handle simply write to `$*OUT`, exactly
as their Perl counterparts write to the currently selected handle.

## Reading whole versus line by line

To close, a rule of thumb that Raku makes easy to follow. If a file is small and
you want it all, `.slurp` or `my @lines = ....lines` is the clearest thing you
can write. If a file is large — or unbounded, like a growing log or a pipe —
iterate the lazy sequence directly and let Raku stream it:

```raku-local
# Small file: fine to hold in memory.
my @config = 'settings.ini'.IO.lines;

# Large file: process one line at a time, constant memory.
my $errors = 'huge.log'.IO.lines.grep(*.contains('ERROR')).elems;
```

The laziness is the default, so the memory-safe choice is also the natural one.
With files, paths, and handles in hand, we have covered how Raku programs talk to
the outside world. Part VIII turns inward, to how you structure the programs
themselves — starting with classes and objects in Chapter 22.

{% include nav.html %}
