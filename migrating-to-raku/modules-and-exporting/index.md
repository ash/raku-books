---
title: Modules, Packages, and Exporting
---

{% include menu.html %}

Sooner or later a program outgrows a single file. In Perl you reach for
`package`, a `use` here and there, and `Exporter` to push names into the caller's
namespace. Raku keeps the same shape — you still declare a namespace, still say
`use`, still choose what leaks out — but the machinery is cleaner and, for once,
built into the language rather than bolted on with a module. This chapter is the
recipe for taking a Perl `.pm` file apart and putting it back together as a
Raku module.

## Loading code: `use`, `need`, `require`

In Perl, `use` loads a module at compile time and runs its `import`; `require`
loads at run time and does not import:

```perl
use List::Util qw(sum);      # compile-time, imports sum
require Some::Heavy::Thing;  # run-time, no import
```

Raku splits the same territory across three keywords. `use` is the everyday one:
it loads at compile time *and* imports whatever the module exports.

```raku-static
use Some::Module;            # compile-time load + import
```

`need` loads a module at compile time but imports *nothing*. You then reach its
symbols through the fully-qualified package name — the moral equivalent of a
Perl `require` that you know will succeed at compile time:

```raku-static
need Greeting;
say Greeting::visible-via-our();   # reach in by full name
```

`require` is the genuinely run-time form. Because it runs when execution reaches
it, the module name can be computed, and you can guard it in a conditional — the
classic "load this plug-in only if we need it" pattern:

```raku-local
my $class = 'Shape';
require ::($class);                         # load a name known only at run time
my $obj = ::($class).new(name => 'square');
say $obj.describe;                          # a shape called square
```

The `::(...)` syntax is *indirect name lookup*: it turns a string into a symbol.
You can also import specific symbols at run time by listing them:

```raku-static
require Greeting <&hello>;    # load now, bring in just &hello
say hello('Runtime');         # Hello, Runtime!
```

## Declaring a namespace: `package` and its kinds

A Perl `.pm` file starts with `package`:

```perl
package Greeting;
# ... subs ...
1;
```

Raku has `package` too, but you almost never write it. Instead you pick the
*kind* of package that matches what you are building — and the most common kind
for a module file is, unsurprisingly, `module`. Save this as `Greeting.rakumod`:

```raku-static
unit module Greeting;

sub hello($name) is export {
    return "Hello, $name!";
}
```

The `unit` prefix means "the rest of the file is inside this declaration", so you
do not have to wrap everything in braces — the direct counterpart of a Perl
file-scoped `package`. Note also that Raku modules need no trailing `1;`.

That ritual is on its way out in Perl too. A `.pm` had to end in a true value
because `require` checked the file's return value, and forgetting it produced the
classic error:

```
Greeting.pm did not return a true value at ...
```

Under `use v5.38` (or `use feature 'module_true'`) the check is gone and the
trailing `1;` is optional:

```perl
use v5.38;
package Greeting;
sub hello { "Hello, $_[0]!" }
```

So this is a convergence rather than a difference — but the `1;` is still on
essentially every `.pm` written before 2023, which is most of them.

`module` is only one of several package kinds, and they all follow the same
`unit`-or-braces pattern. You already know two of the others from earlier
chapters:

| Kind      | Declares                         | Covered in |
|-----------|----------------------------------|------------|
| `module`  | a plain namespace of subs/vars   | this chapter |
| `class`   | an object type                   | Chapter 22 |
| `role`    | a reusable behaviour             | Chapter 23 |
| `grammar` | a namespace of named regexes     | Chapter 19 |

So `unit class Shape;` and `unit grammar INI;` are the same idea as
`unit module Greeting;`, differing only in what kind of thing they introduce. A
file can even hold several of them if you use the brace form rather than `unit`.

## What is visible: `our` versus `my`

Inside a package, the choice between `my` and `our` decides reachability, exactly
as it did in Perl — `my` is lexical and private to the file, `our` is a package
variable visible through the namespace:

```raku-static
unit module Greeting;

our sub visible-via-our() { "reached through the package name" }
my  sub hidden()          { "you cannot see me" }
```

From outside, `Greeting::visible-via-our()` works and `Greeting::hidden()` does
not. This is the same distinction Perl draws between an `our`/fully-qualified
sub and a `my` lexical one. But note the key difference from Perl habit: making
a sub reachable through the package name is *not* the same as exporting it.
Reaching in by full name always works for `our`; exporting is a separate,
opt-in act.

## Exporting: `is export` instead of `Exporter`

Here is where the Perl boilerplate melts away. The traditional incantation —

```perl
package Greeting;
use Exporter 'import';
our @EXPORT_OK = qw(hello goodbye);
our @EXPORT    = qw(hello);
```

— becomes a single trait on the sub itself. Mark a routine `is export` and it is
imported by default when someone says `use Greeting`:

```raku-static
sub hello($name) is export { "Hello, $name!" }
```

To put a sub behind a named tag — the equivalent of `@EXPORT_OK`, an export the
caller must ask for — give `export` an argument:

```raku-static
sub goodbye($name) is export(:formal) { "Farewell, $name." }
```

A sub can belong to several tags at once, and a plain `is export` is shorthand
for the built-in `:DEFAULT` tag:

```raku-static
sub a() is export(:one)       { 'a' }
sub b() is export(:two)       { 'b' }
sub c() is export(:one, :two) { 'c' }
```

## Importing selectively

The caller controls what arrives. With no arguments, `use` brings in the
`:DEFAULT` set:

```raku-static
use Greeting;
say hello('Ada');         # Hello, Ada!
```

Naming a tag imports that group instead (and defaults are then *not* pulled in
unless you also ask for them):

```raku-static
use Greeting :formal;
say goodbye('Ada');       # Farewell, Ada.
```

You can ask for several tags in one go:

```raku-static
use Multi :one, :two;
say a(), b(), c();        # abc
```

This tag system is Raku's answer to the `use Module qw(...)` import list: instead
of the module author listing individual names, related exports are grouped, and
the caller opts into groups. It scales far better than a flat `@EXPORT_OK`.

## The `sub EXPORT` alternative

For full control — when what you export depends on the arguments to `use`, or
must be computed — define a `sub EXPORT`. It receives the positional arguments
from the `use` statement and returns a map from symbol name to value. This is the
Raku parallel of writing a custom `import` in Perl:

```raku-static
sub EXPORT(*@names) {
    my %exports;
    for @names -> $n {
        %exports{'&' ~ $n} = sub { "you asked for $n" };
    }
    return %exports;
}
```

```raku-static
use Dynamic <foo bar>;
say foo();                # you asked for foo
say bar();                # you asked for bar
```

The `&` sigil in the key marks the exported symbol as a subroutine. Reach for
`sub EXPORT` only when `is export` cannot express what you need; for the vast
majority of modules, tags are enough.

## Versions and authority

Perl modules carry a `$VERSION` string that the toolchain reads. Raku bakes
version — and *authority*, meaning who published it — into the language, both on
the declaration and on the `use`:

```raku-static
unit module Widget:ver<1.2.3>:auth<zef:andrew>;
```

```raku-static
use Widget:ver<1.2.3>;
```

`:ver` is a version, `:auth` an authority string (commonly `zef:username` for the
modern ecosystem). When several versions of a distribution are installed, the
`:ver` on your `use` selects which one loads — so two programs on the same machine
can depend on incompatible versions without conflict, something Perl handles
only awkwardly. Version selection is enforced for *installed* distributions;
loose files found via `-I` (below) are matched by name only, so a `:ver`
constraint against a bare file is not checked.

## Documenting it: POD becomes Pod6

A Perl module carries its documentation inline, in POD, and `perldoc` renders it:

```perl
package Greeting;

=head1 NAME

Greeting - a friendly greeter

=head2 hello($name)

Returns a greeting for C<$name>.

=cut

sub hello { "Hello, $_[0]!" }
1;
```

Raku's version is **Pod6**, and the family resemblance is deliberate. The
directives are the same words; what changed is that a block now has an explicit
beginning and end, so there is no `=cut` and no ambiguity about where prose stops
and code resumes:

```raku-static
=begin pod

=head1 Greeting

A friendly greeter.

=end pod

unit module Greeting;

sub hello($name) is export { "Hello, $name!" }
```

`raku --doc Greeting.rakumod` renders it, the way `perldoc` does:

```
Greeting

A friendly greeter.
```

`=head1` through `=head4`, `=item`, `=code`, and `=table` cover most of what you
used POD for, and the inline formatting codes are the familiar ones — `B<bold>`,
`I<italic>`, `C<code>`, `L<links>`.

### Documentation attached to the code: `#|` and `.WHY`

Here is the part with no POD equivalent. A comment starting `#|` is a
**declarator block**: it attaches to the declaration that follows it, and stays
attached at run time, reachable through the `.WHY` method.

```raku
#| Returns a greeting for the given name.
sub hello($name) { "Hello, $name!" }

say &hello.WHY;      # Returns a greeting for the given name.
```

The `#=` form does the same from *below* the declaration, for the trailing-comment
style. Because the text is a real object rather than a block of prose the compiler
skipped over, tooling can read it: this is what lets an editor show a signature
and its description together, and what documentation generators walk. The whole
Pod tree of the current file is likewise available as data, in `$=pod`.

The practical upshot for a migrating programmer is that the two habits separate
cleanly. Reach for `=begin pod` for the module's manual — the part a reader
consumes with `--doc`. Reach for `#|` for the one-line "what does this routine
do" note that used to live in an ordinary `#` comment and was invisible to
everything but a human reading the source.

## Where modules live: the search path

Perl searches `@INC`, which you extend with `-I`, `PERL5LIB`, or `use lib`.
Raku has the exact same three levers, renamed:

```
$ raku -I lib program.raku          # add ./lib to the search path
$ RAKULIB=lib raku program.raku     # the PERL5LIB counterpart
```

```raku-static
use lib 'lib';                       # the use lib counterpart
use Greeting;
```

Under the hood the search path is a chain of *repositories* (you can inspect it
with `raku -e 'say $*REPO.repo-chain'`), but for day-to-day work the three forms
above are all you need.

Putting it together, here is a complete, runnable module and program. Save the
first as `lib/Greeting.rakumod`:

```raku-static
unit module Greeting;
sub hello($name) is export { "Hello, $name!" }
```

and the second as `use-it.raku`:

```raku-static
use Greeting;
say hello('World');
```

then run it with the library path pointed at `lib`:

```
$ raku -I lib use-it.raku
Hello, World!
```

That `-I lib` is fine while developing, but the moment you want to *share* a
module — or pull one down that someone else wrote — you need the ecosystem and
its installer. That is `zef`, and it is where the next chapter begins.

{% include nav.html %}
