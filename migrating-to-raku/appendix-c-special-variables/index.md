---
title: Appendix C — Special Variables
---

{% include menu.html %}

Perl's punctuation variables are one of the things migrating programmers miss
most sharply — not because they are gone, but because most of them have moved.
Two ideas explain nearly all of the changes. First, the global environment
variables now carry the *dynamic* twigil `*` (`$*PID`, `@*ARGS`, `%*ENV`),
which is why you can temporarily rebind them without global damage (Chapter 3).
Second, the match result `$/` is a real `Match` object, so the capture
variables are properties of it and are numbered from **zero**.

Everything in the "Raku" column below has been checked under Rakudo v2026.07.

## The topic and arguments

| Perl | Raku | Notes |
|--------|------|-------|
| `$_` | `$_` | still the topic; a leading-dot method (`.say`) acts on it |
| `@_` | signature params / `@_` | prefer a real signature; `@_` still exists in a bare block |
| `$a`, `$b` (sort) | `$a`, `$b` or `$^a`, `$^b` | placeholder parameters work in any block |
| `wantarray` | — (gone) | context is decided by the container, not queried; no `want` builtin |

## Program and process

| Perl | Raku | Notes |
|--------|------|-------|
| `@ARGV` | `@*ARGS` | command-line arguments |
| `%ENV` | `%*ENV` | environment; `%*ENV<HOME>` |
| `$0` (program name) | `$*PROGRAM-NAME` | the string name; `-e` for `-e` one-liners |
| `$0` (program name) | `$*PROGRAM` | the same thing as an `IO::Path` object |
| `$$` | `$*PID` | process id |
| `$^X` | `$*EXECUTABLE` | the interpreter (`IO::Path`); `$*EXECUTABLE-NAME` for the name |
| `%SIG` | `%*SIG` / `signal(...)` | signal handling (also the `signal` Supply) |
| `$^O` | `$*KERNEL.name` / `$*DISTRO` | OS and distribution introspection |

## Standard handles

| Perl | Raku | Notes |
|--------|------|-------|
| `STDIN` | `$*IN` | an `IO::Handle`; `$*IN.lines`, `get` |
| `STDOUT` | `$*OUT` | `say`/`print` write here |
| `STDERR` | `$*ERR` | `note` writes here |
| `<>` / `<STDIN>` | `$*ARGFILES` / `lines()` | the magic input over `@*ARGS` or STDIN |

Because these are dynamic variables, redirection is local and tidy — rebind
`$*OUT` inside a block and it reverts on the way out, no glob juggling:

```raku
{
    my $*OUT = open "/tmp/log.txt", :w;
    say "this goes to the file";      # captured by the rebound handle
    $*OUT.close;
}
say "this goes to the screen";        # $*OUT is the terminal again
```

## Separators and formatting

| Perl | Raku | Notes |
|--------|------|-------|
| `$/` (input record sep) | `$*IN.nl-in` | per-handle; a list of accepted line endings |
| `$\` (output record sep) | — | no global; use `say`, which adds `\n` |
| `$,` (output field sep) | — | no global; use `.join(",")` |
| `$"` (list separator) | — | no global; interpolation joins with a space; use `.join` |
| `$;` (subscript sep) | — | multi-dim subscripts are native: `%h{$x; $y}` |

## Matching

| Perl | Raku | Notes |
|--------|------|-------|
| `$/` (after a match) | `$/` | now a `Match` object, not the input separator |
| `$1`, `$2`, `$3` … | `$0`, `$1`, `$2` … | captures are **0-based** aliases of `$/[0]`, `$/[1]` … |
| `$+{name}` | `$<name>` | named capture; alias of `$/<name>` |
| `$&` (whole match) | `$/` / `$/.Str` | the `Match` stringifies to the matched text |
| `` $` `` / `$'` | `$/.prematch` / `$/.postmatch` | before/after the match |
| `@-` / `@+` | `$/.from` / `$/.to` | match offsets (methods on `Match`) |

```raku
if "John 42" ~~ /(\w+) \s+ (\d+)/ {
    say $0;          # ｢John｣   captures are numbered from zero
    say $1;          # ｢42｣
    say $/.Str;      # John 42  the whole match
}
```

One difference bites in translation: in Perl, a named capture is *also* numbered,
so `$1` and `$+{name}` are the same group. In Raku a name takes the group out of
the positional numbering altogether, and the groups that remain close the gap:

```raku-nobrowser
if "John 42" ~~ /$<name>=(\w+) \s+ (\d+)/ {
    say $<name>;     # ｢John｣   the named group
    say $0;          # ｢42｣     the digits — the only *numbered* group left
    say $/.Str;      # John 42
}
```

## Errors

| Perl | Raku | Notes |
|--------|------|-------|
| `$@` (eval error) | `$!` | the caught exception object after `try` |
| `$!` (errno / OS error) | `$!` | the same variable holds the last exception; it carries the OS error |
| `$?` (child exit status) | `$!` / `Proc` | `run`/`Proc::Async` return a `Proc` with `.exitcode` |

The consolidation is deliberate: Perl spread failure information across `$@`,
`$!`, and `$?`; Raku funnels it into one place, the exception in `$!`, which is
a full object you can interrogate:

```raku-nobrowser
my $fh = try open "/no/such/file";
say $!.^name;        # X::AdHoc  (or a more specific X::IO subtype)
say $!.defined;      # True
```

## Modules and library paths

| Perl | Raku | Notes |
|--------|------|-------|
| `@INC` | `$*REPO` | a chain of `CompUnit::Repository` objects, not a plain path list |
| `PERL5LIB` (env) | `RAKULIB` (env) | prepend extra search paths; also `-I` on the command line |
| `%INC` | — | no direct equivalent; loading is tracked by the repository chain |
| `__FILE__` | `$?FILE` | compile-time source file (a `$?` twigil, Chapter 3) |
| `__LINE__` | `$?LINE` | compile-time line number |
| `__PACKAGE__` | `$?PACKAGE` / `::?PACKAGE` | current package/class at compile time |

```raku-nobrowser
say $*REPO.repo-chain;   # (inst#…/.raku inst#…/site … ap# nqp# perl5#)
```

A last word of comfort: you very rarely *need* these day to day. Signatures
replace `@_`, `$*IN.lines` replaces `<STDIN>`, and typed exceptions replace the
`$@`/`$!`/`$?` juggling act. Reach for this table when porting old code, not
when writing new.

{% include nav.html %}
