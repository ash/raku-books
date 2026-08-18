---
title: Phasers
---

{% include menu.html %}

Perl gives you a small, fixed set of special code blocks that run at moments
other than "right here, in order": `BEGIN`, `END`, and — less often used —
`INIT` and `CHECK`. They fire at particular *phases* of a program's life. Raku
takes that idea and generalises it into a whole family of blocks called
*phasers*, covering not just compile and run time but also block entry and exit,
success and failure, and each turn of a loop. Once you see the pattern, a lot of
code that Perl wrote with flags and clean-up variables disappears.

A phaser is written as an uppercase keyword followed by a block (or, for a single
statement, no braces at all). It is not called; the runtime fires it at the right
moment. Its position in the source does not determine when it runs.

## The Perl phasers, and their Raku equivalents

Perl's compile/run-time blocks all survive in Raku with the same names and
essentially the same meanings. Here they are in Perl:

```perl
use v5.10;
say 'body starts';
BEGIN { say 'BEGIN' }
END   { say 'END' }
INIT  { say 'INIT' }
CHECK { say 'CHECK' }
say 'body ends';
```

```
BEGIN
CHECK
INIT
body starts
body ends
END
```

And the same four in Raku, written in the terser single-statement form:

```raku
say 'program body starts';
BEGIN say 'BEGIN';
CHECK say 'CHECK';
INIT  say 'INIT';
END   say 'END';
say 'program body ends';
```

```
BEGIN
CHECK
INIT
program body starts
program body ends
END
```

The ordering is identical to Perl, and for the same reasons:

- **`BEGIN`** runs as soon as it is *compiled* — before the rest of the program
  even finishes compiling. Use it for work whose result you need at compile time.
- **`CHECK`** runs when compilation is *complete*, in reverse order of
  declaration.
- **`INIT`** runs once, at run time, just before the main body executes.
- **`END`** runs once, at program shutdown — clean-up, final reports, and so on.

If you never learn another phaser, these four already work the way your Perl
instincts expect.

## Block-entry and block-exit phasers

Here is where Raku goes beyond Perl. Any block — a subroutine, a loop body, a
bare block — can carry phasers that fire as control *enters* and *leaves* it. This
is the mechanism Perl programmers hand-rolled with a guard variable and an
`END`-like clean-up at the bottom of a sub.

- **`ENTER`** runs every time the block is entered.
- **`LEAVE`** runs every time the block is left, *however* it is left — normal
  return, `last`, an exception, anything. This is Raku's answer to `try`/`finally`.
- **`KEEP`** runs on leaving only if the block completed *successfully*.
- **`UNDO`** runs on leaving only if the block was exited *unsuccessfully* (an
  exception, or a failure).

```raku
sub work {
    ENTER say '  ENTER';
    LEAVE say '  LEAVE';
    KEEP  say '  KEEP (on success)';
    UNDO  say '  UNDO (on failure)';
    say '  body';
}
say 'before';
work();
say 'after';
```

```
before
  ENTER
  body
  KEEP (on success)
  LEAVE
after
```

Notice that although `LEAVE` is written *above* the body, it fires *after* it —
position in the source is irrelevant. `KEEP` runs before `LEAVE` because the
success/failure decision is made first, then the unconditional exit code runs.

`UNDO` only shows itself when the block is abandoned. The classic use is pairing
it with `KEEP` to commit or roll back:

```raku
sub risky($ok) {
    KEEP say '  KEEP: succeeded';
    UNDO say '  UNDO: failed';
    die 'boom' unless $ok;
    return 'value';
}
say risky(True);
try { risky(False) }
```

```
  KEEP: succeeded
value
  UNDO: failed
```

Because `LEAVE` always runs, you no longer need to remember to close a handle or
release a lock on every exit path — you declare the clean-up once, next to the
thing it cleans up.

## Loop phasers

Loops get three phasers of their own, which fire relative to iterations rather
than to the whole loop:

- **`FIRST`** runs once, before the first iteration.
- **`NEXT`** runs at the end of each iteration, before the next begins.
- **`LAST`** runs once, after the final iteration.

```raku
for 1..3 {
    FIRST say "FIRST (before first iteration)";
    NEXT  say "  NEXT after iteration $_";
    LAST  say "LAST (after last iteration)";
    say "body $_";
}
```

```
FIRST (before first iteration)
body 1
  NEXT after iteration 1
body 2
  NEXT after iteration 2
body 3
  NEXT after iteration 3
LAST (after last iteration)
```

In Perl you would fake `FIRST` with a `state`-guarded `if` at the top of the
loop, and `NEXT` with a `continue` block. Raku names all three directly. (Do not
confuse the `NEXT` phaser with the `next` loop-control keyword from Chapter 12 —
one is a block that runs after each iteration, the other jumps to the next
iteration.)

## `PRE` and `POST`

Two more phasers assert conditions rather than running side effects. `PRE`
checks a condition on entry and `POST` checks one on exit; if either returns a
false value, the runtime throws. They are a lightweight design-by-contract
facility with no Perl equivalent:

```raku-nobrowser
sub sqrt-positive($n) {
    PRE  { $n >= 0 }
    POST { $_ >= 0 }
    return $n.sqrt;
}
say sqrt-positive(16);              # 4
try { say sqrt-positive(-4) }
say "caught: {$!.^name}" if $!;     # caught: X::Phaser::PrePost
```

Inside `POST`, the topic `$_` is bound to the value the block is about to return,
so you can assert something about the result. A failed `PRE` or `POST` raises an
`X::Phaser::PrePost` exception.

## Seeing the order all at once

Phasers are easiest to trust once you have watched them interleave in a single
program. This one exercises the compile-time, run-time, and loop phasers
together:

```raku-local
BEGIN say 'BEGIN  compile time';
INIT  say 'INIT   run time, before body';
say 'body';
for 1..2 {
    FIRST say '  FIRST';
    NEXT  say '  NEXT';
    LAST  say '  LAST';
    say "  iter $_";
}
END say 'END    program shutdown';
```

```
BEGIN  compile time
INIT   run time, before body
body
  FIRST
  iter 1
  NEXT
  iter 2
  NEXT
  LAST
END    program shutdown
```

The takeaway is the same one that makes phasers worth learning: *where* you write
a phaser is documentation of what it is for, while *when* it runs is fixed by its
keyword. You put the clean-up next to the setup, the loop summary next to the
loop, the compile-time work next to the code that needs it — and the runtime
sorts out the timing.

That habit — declaring code near what it relates to and letting the language
schedule it — carries straight into the next part of the book, where subroutine
signatures replace `@_` and let you declare, up front, exactly what a routine
expects.

{% include nav.html %}
