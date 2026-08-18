---
title: Errors, Exceptions, and Failures
---

{% include menu.html %}

Error handling in classic Perl is a set of conventions rather than a feature:
you `die`, you wrap risky code in `eval`, and you inspect `$@`. Modern Perl has
since grown a native `try`/`catch` (with `finally`), so the basic shape is now
shared ground. Raku takes it further: exceptions are proper objects arranged in
a hierarchy, `try` is an *expression*, `CATCH` does typed dispatch inside any
block, and there is a genuinely new idea — the soft *Failure* — that lets an
error travel quietly until someone actually looks at it.

## `die` and `eval` become `die` and `try`

The Perl pattern is familiar muscle memory: wrap the risky part in `eval`, then
test `$@`.

```perl
use v5.10;
my $r = eval { 10 / 0; 1 };
if (!defined $r) {
    say "caught: $@";          # caught: Illegal division by zero at ... line 2.
}
```

Modern Perl can tidy this into a native `try`/`catch`:

```perl
use feature 'try';
try  { my $r = 10 / 0 }
catch ($e) { warn "caught: $e" }
```

Raku keeps `die` for raising an error, and it too spells the wrapper `try` — but
with a twist Perl's does not have: `try` is an *expression*. It returns the value
of the block on success, or `Nil` if the block died.

```raku
my $result = try { 10 / 2 };
say $result;                   # 5

my $bad = try { die "boom" };
say $bad.defined;              # False
```

There is no `$@`. After a `try`, the exception that was caught lives in `$!`:

```raku
my $bad = try { die "boom" };
say $!.message;                # boom
```

Note the shift in meaning of `$!`. In Perl `$!` is the OS error string (`errno`);
in Raku that role moves elsewhere and `$!` holds the most recent caught
exception. If the `try` block succeeds, `$!` is undefined.

## The `CATCH` block

`eval`/`$@` tests for failure *after the fact*. Raku's real workhorse is the
`CATCH` block, which you place *inside* any block — not just a `try`. It behaves
like a `given`/`when` on the thrown exception: the exception becomes the topic,
and you match it with `when` clauses and a `default`.

```raku
my $x = try {
    die "something failed";
    CATCH {
        default {
            say "caught: ", .message;    # caught: something failed
        }
    }
}
say "after";                             # after
```

The `CATCH` block does not have to sit in a `try`; drop it into any ordinary
block and that block gains exception handling. A `CATCH` whose `when`/`default`
handles the exception *contains* it — control continues after the enclosing
block rather than unwinding further.

## Exceptions are objects

Every exception in Raku is an object, and they live in a hierarchy rooted at
`Exception` whose type names begin with `X::`. When you `die` with a plain
string, Raku quietly wraps it in an `X::AdHoc` for you — the string becomes the
exception's *payload*:

```raku-nobrowser
try {
    die "plain string death";
    CATCH { default { say .^name, ": ", .message } }
}
# X::AdHoc: plain string death
```

So the string form is not a lesser thing; it is an `X::AdHoc` with syntactic
sugar. You can construct one explicitly, but note that `X::AdHoc` carries its
text in `payload`, not `message`:

```raku-nobrowser
try {
    X::AdHoc.new(payload => "adhoc problem").throw;
    CATCH { default { say .^name, ": ", .message } }
}
# X::AdHoc: adhoc problem
```

The wider `X::` hierarchy is populated by the built-ins. Divide by zero throws
`X::Numeric::DivideByZero`; a failed type check throws `X::TypeCheck`; assigning
to a read-only value throws `X::Assignment::RO` (you met that one in Chapter 4).
Because they are typed, you can catch precisely the kind you expect and let the
rest propagate:

```raku
try {
    X::AdHoc.new(payload => "adhoc problem").throw;
    CATCH {
        when X::AdHoc { say "adhoc: ", .message }    # adhoc: adhoc problem
        default       { say "other: ", .message }
    }
}
say "still going";                                   # still going
```

## Custom exceptions

In Perl, a structured exception means `die`-ing with a reference — often a
blessed object, often a bare hash — and remembering to check `ref $@`:

```perl
use v5.10;
eval { die { code => 42, msg => "structured" }; };
if (ref $@ eq 'HASH') {
    say "object death: $@->{msg}";        # object death: structured
}
```

Raku gives you a real class. Subclass `Exception`, add attributes, and provide a
`message` method — that method is what `.message` and the default report use:

```raku
class X::Temperature is Exception {
    has $.degrees;
    method message { "Temperature $!degrees is out of range" }
}

try {
    X::Temperature.new(degrees => 200).throw;
    CATCH {
        when X::Temperature { say "caught: ", .message }
    }
}
# caught: Temperature 200 is out of range
```

Prefixing the class name with `X::` is a convention, not a requirement, but it
signals intent and slots your type neatly beside the built-in ones. You raise it
with `.throw`; there is no need to `die` an object you have already built.

## Resuming

Some conditions are recoverable: you want to note them, then carry on from the
point of the throw. That is what `.resume` does — call it inside the handler and
execution continues *after* the statement that threw.

```raku
class X::Retryable is Exception {
    method message { "please resume" }
}
{
    X::Retryable.new.throw;
    say "resumed and continued";
    CATCH {
        when X::Retryable { say "handling, then resuming"; .resume }
    }
}
# handling, then resuming
# resumed and continued
```

Perl has no equivalent; once you have `die`d, the stack is gone. Resumable
exceptions are the machinery behind `warn`, which we meet next.

## `warn` and the `CONTROL` block

`warn` in Raku prints to standard error and then *resumes* — it is a resumable
control exception, not a fatal one:

```raku
sub risky {
    warn "just a warning";
    say "continued after warn";
}
risky();
# just a warning       (on STDERR, with a backtrace)
# continued after warn
```

Where `CATCH` intercepts thrown exceptions, its sibling `CONTROL` intercepts
*control* exceptions — the events raised by `warn`, `return`, `next`, `last`, and
friends. To capture warnings (rather than let them reach the screen), match
`CX::Warn` and `.resume`:

```raku
sub noisy {
    warn "disk almost full";
    say "work done";
    CONTROL {
        when CX::Warn { note "logged warning: {.message}"; .resume }
    }
}
noisy();
# logged warning: disk almost full
# work done
```

This is the clean replacement for Perl's `$SIG{__WARN__}` handler: instead of a
global signal hook, you scope warning handling to exactly the block you care
about.

## Soft errors: `Failure`

Here is the idea with no Perl counterpart. Sometimes you do not want to throw
*immediately* — you want to return an error-shaped value that behaves like
`undef` if the caller merely checks it, but explodes into a full exception the
moment anyone tries to *use* it. That is a `Failure`, and you produce one with
`fail` instead of `die`.

```raku-local
sub get-config($file) {
    return fail "no such file: $file" unless $file.IO.e;
    return $file.IO.slurp;
}

my $c = get-config("/does/not/exist");
say $c.defined;              # False
say $c ~~ Failure;           # True
```

The `fail` did not throw. `$c` is an undefined `Failure` you can test calmly. But
touch its value — call a method, do arithmetic — and the wrapped exception is
thrown for real:

```raku-static
try {
    my $len = $c.chars;
    CATCH { default { say "threw when used: ", .message } }
}
# threw when used: no such file: /does/not/exist
```

This gives you the best of both styles. A caller who wants the lightweight,
check-the-return-value approach can use the defined-or operator; a caller who
would rather have an exception simply uses the value and lets it throw:

```raku
sub half($n) {
    fail "odd number: $n" if $n % 2;
    $n / 2;
}
my $v = half(7) // 'skipped';           # never throws
say $v;                                 # skipped
with half(8) -> $ok { say "ok: $ok" }   # ok: 4
```

A `Failure` also throws automatically if it is garbage-collected without ever
being examined, so an error you forget to handle will not vanish silently. It is
Raku's way of letting an error stay soft exactly as long as nobody has looked at
it — and no longer.

With errors under control, we can turn to a style of programming where values,
not side effects, do the work: functional Raku.

{% include nav.html %}
