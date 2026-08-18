---
title: Concurrency and Parallelism
---

{% include menu.html %}

Concurrency in Perl is a patchwork. You can `fork` and juggle process ids and
`waitpid`; you can use `threads`, with all the caveats that entails; or you can
pull in an event framework such as `AnyEvent` or `IO::Async` and adopt its whole
world-view. Each works, but each is a bolt-on with its own conventions. Raku
folds concurrency into the core language and gives it a single, coherent model:
`Promise` for "a value that will arrive later", `Channel` and `Supply` for
streams of values, and a couple of one-word switches for data parallelism.
Nothing in this chapter needs a module.

## `fork` becomes `start`

The Perl way to do three things at once is to fork three children and reap
them:

```perl
use v5.10;
my @pids;
for my $n (1..3) {
    my $pid = fork // die "cannot fork";
    if ($pid == 0) {
        say "child $n computed ", $n * $n;
        exit;
    }
    push @pids, $pid;
}
waitpid($_, 0) for @pids;
say "all children done";
```

In Raku you write `start`, which schedules a block on the thread pool and
immediately hands you back a `Promise` — an object standing in for the result
that is not ready yet. You retrieve the result with `await`.

```raku-async
my $p = start { 2 ** 10 };
say await $p;                 # 1024
```

`await` on a list of promises waits for all of them and returns all their
results, in order:

```raku-async
my @promises = (1..3).map: -> $n { start { $n * $n } };
say await @promises;          # (1 4 9)
```

No process ids, no manual reaping, and the value comes straight back rather than
having to be printed by a child or shuttled through a pipe. The thread pool sizes
itself; you just describe the work.

## Combining and chaining promises

Two class methods combine promises. `Promise.allof` yields a promise that is kept
when *all* the given promises finish; `Promise.anyof` when the *first* one does.
After an `allof`, read the individual results with `.result`:

```raku-async
my @jobs = (1..3).map: -> $n { start { $n * 10 } };
await Promise.allof(@jobs);
say @jobs>>.result;           # [10 20 30]
```

To do something *when* a promise finishes rather than blocking on it, use
`.then`, which chains a follow-on computation:

```raku-async
my $p = start { 42 };
my $q = $p.then({ .result + 1 });
say await $q;                 # 43
```

This is the same idea as a callback in an event loop, but expressed as an
ordinary value you can pass around, store, and combine.

## `Channel`: a producer/consumer queue

When one part of the program produces items and another consumes them, a
`Channel` is the thread-safe queue between them. The producer calls `.send` and
finally `.close`; the consumer iterates with `.list`, which blocks for items and
ends when the channel closes.

```raku-async
my $ch = Channel.new;
my $producer = start {
    $ch.send($_) for 1..5;
    $ch.close;
}
my @received;
for $ch.list -> $item { @received.push: $item * 2 }
await $producer;
say @received;                # [2 4 6 8 10]
```

This is the pattern you would build by hand with a shared array, a lock, and a
condition variable in threaded Perl — here it is one built-in class with no
locking on your part.

## `Supply`, `react`, and `whenever`

A `Channel` is pulled by its consumer; a `Supply` is *pushed* — it is Raku's
reactive stream, an asynchronous sequence of values that arrive over time
(events, ticks, lines from a socket). You consume a supply inside a `react`
block, declaring `whenever` handlers that fire for each emitted value. The
`react` block runs until all its supplies are done.

```raku-async
my $supply = Supply.from-list(1..5);
my @squares;
react {
    whenever $supply -> $v {
        @squares.push: $v * $v;
    }
}
say @squares;                 # [1 4 9 16 25]
```

A single `react` block can hold several `whenever`s — one per input stream — which
is how you write an event loop that watches a timer, a socket, and a signal at
once, without any callback pyramid. `Supply` is the piece that replaces
`AnyEvent`, and it is part of the language.

## Data parallelism: `.hyper` and `.race`

The examples above are about *concurrency* — overlapping tasks. For *parallelism*
— spreading one big computation across cores — Raku offers two drop-in methods.
Insert `.hyper` into a chain and the `map`/`grep` that follows runs in parallel
across worker threads, **preserving order**:

```raku
my @out = (1..10).hyper.map(* ** 2);
say @out;                     # [1 4 9 16 25 36 49 64 81 100]
```

`.race` does the same but does **not** promise to keep the original order, which
lets it be a touch faster when order does not matter:

```raku
say (1..1000).race.grep(*.is-prime).elems;   # 168
```

These help when the per-element work is substantial and the list is large; for
cheap operations the coordination overhead outweighs the gain, so measure before
reaching for them. The beauty is that turning a sequential pipeline into a
parallel one is a single word.

## Atomics

When several threads update the same integer, ordinary `++` can lose updates.
Declare the variable as `atomicint` and increment it atomically — either with the
`atomic-fetch-inc` routine or the `⚛` (U+269B) operator forms:

```raku-async
my atomicint $counter = 0;
my @workers = (1..10).map: {
    start { atomic-fetch-inc($counter) for 1..1000; }
}
await @workers;
say $counter;                 # 10000
```

The `⚛` operators are the concise spelling of the same operations:

```raku
my atomicint $x = 0;
$x⚛++;
$x⚛++;
say $x;                       # 2
```

For anything more elaborate than a counter, prefer a `Channel` or `Supply` to
shared mutable state — message passing sidesteps whole classes of race
conditions.

## External processes: `Proc::Async`

For running and interacting with external programs asynchronously, `Proc::Async`
gives you their output as supplies, so you can react to lines as they appear:

```raku-async
my $proc = Proc::Async.new('echo', 'hello from a child');
my @lines;
react {
    whenever $proc.stdout.lines { @lines.push: $_ }
    whenever $proc.start        { done }
}
say @lines;                   # [hello from a child]
```

`whenever $proc.start` gives a promise that is kept when the process exits;
calling `done` then finishes the `react` block. This is the asynchronous
counterpart to backticks and `open`-to-a-pipe, and it composes with everything
else in this chapter.

That is the whole model: `start` and `await` for tasks, `Channel` and `Supply`
for streams, `.hyper`/`.race` for parallel data, atomics for the rare shared
counter — all built in. With robustness and concurrency behind us, the final
chapter is a grab-bag of idioms, gotchas, and the one-liners that make Raku a joy
at the command line.

{% include nav.html %}
