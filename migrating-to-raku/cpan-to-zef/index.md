---
title: CPAN to zef, and Mixing Languages
---

{% include menu.html %}

Perl's greatest asset was never the language — it was CPAN, and the `cpan` and
`cpanm` clients that made "there is a module for that" a reflex. Raku has its own
ecosystem, its own installer, and its own distribution format. This chapter maps
the muscle memory across: where the modules live, how you install them, what a
distribution looks like on disk, and how you publish your own. Then, because you
do not have to throw CPAN away, it shows how to call Perl — and C — straight
from Raku.

## The installer: `cpanm` becomes `zef`

Where you reach for `cpanm` in Perl, you reach for `zef` in Raku. It ships with
Rakudo Star and the common distributions, so `which zef` should already find it.
The verbs line up almost one for one:

```
$ cpanm Some::Module           # Perl
$ zef install Some::Module     # Raku
```

`zef` does rather more than install. The subcommands you will use most:

```
$ zef install Cro::HTTP        # download, build, test, and install
$ zef uninstall Cro::HTTP      # remove it again
$ zef test .                   # run the tests of the distribution in .
$ zef search JSON              # find distributions matching a term
$ zef info JSON::Fast          # show metadata for one distribution
$ zef upgrade                  # upgrade installed distributions
$ zef update                   # refresh the package indexes (like cpan's index)
```

Unlike `cpanm`, `zef` runs a distribution's full test suite by default before
installing, and refuses to install if the tests fail — so a green install really
means "it passed its tests on your machine".

## Where the modules live

CPAN is a single index served by many mirrors. The Raku world settled, after some
history, on a different arrangement. Modules are published to the **`fez`/zef
ecosystem** (the `fez` uploader pushes to a service that `zef` reads), and you
browse the whole catalogue at **raku.land**, the modern equivalent of
MetaCPAN. Older modules still resolve through the CPAN-backed and GitHub-backed
indexes, and `zef` knows how to search all of them, so from your side it is one
command regardless of where a given module physically lives.

One point of reassurance for the Perl programmer: **CPAN itself is not off
limits.** Later in this chapter we call Perl modules directly, so the tens of
thousands of mature CPAN distributions remain within reach from Raku.

## A distribution on disk

A Perl distribution is described by a `Makefile.PL` or `dist.ini` and a
`MANIFEST`. A Raku distribution is described by a single JSON file,
**`META6.json`**, at the root. A minimal one looks like this:

```
{
  "name"       : "Greeting",
  "version"    : "1.0.0",
  "auth"       : "zef:andrew",
  "description": "A friendly greeter",
  "provides"   : {
    "Greeting" : "lib/Greeting.rakumod"
  },
  "depends"    : [ "JSON::Fast" ],
  "license"    : "Artistic-2.0"
}
```

The important fields:

- **`name`** and **`version`** — the identity of the distribution, matching the
  `:ver` machinery from Chapter 24.
- **`provides`** — a map from each module's *name* to the *file* that implements
  it. This is what lets `use Greeting;` find `lib/Greeting.rakumod`. There is no
  separate `MANIFEST` to keep in sync; `provides` is the manifest.
- **`depends`** — the list of other distributions to install first, the
  counterpart of `PREREQ_PM` / `requires`.

The surrounding directory layout will feel entirely familiar, because it mirrors
CPAN convention:

```
Greeting/
├── META6.json
├── lib/
│   └── Greeting.rakumod      # the module(s), named per provides
├── t/
│   └── 01-basic.rakutest     # tests, run by `zef test .`
└── bin/
    └── greet                 # installable command-line scripts
```

`lib/` holds modules, `t/` holds tests (`zef test .` runs them), and anything in
`bin/` is installed onto the user's `PATH` — the equivalent of a Perl
distribution's `script/` or `bin/`.

## Writing the tests: `Test::More` becomes `Test`

The `t/` directory above is not decoration — `zef` runs it before it installs
anything, so a distribution without tests is a distribution nobody can trust. The
good news is that the test module you know maps across almost name for name.

A Perl test file uses `Test::More`:

```perl
use v5.36;
use Test::More tests => 3;

ok 1 + 1 == 2,              'addition works';
is 'a' . 'b', 'ab',         'concatenation works';
is_deeply [1, 2], [1, 2],   'lists compare deeply';
```

```
1..3
ok 1 - addition works
ok 2 - concatenation works
ok 3 - lists compare deeply
```

The Raku equivalent is the core `Test` module — no installation, it ships with
the compiler. Save this as `t/01-basic.rakutest`:

```raku
use Test;

plan 4;

ok  1 + 1 == 2,            'addition works';
is  'a' ~ 'b', 'ab',       'concatenation works';
is-deeply [1, 2], [1, 2],  'lists compare deeply';
dies-ok { die 'boom' },    'it dies when it should';
```

```
1..4
ok 1 - addition works
ok 2 - concatenation works
ok 3 - lists compare deeply
ok 4 - it dies when it should
```

That is TAP, the same protocol `prove` has consumed for twenty years, so the
output should look reassuringly familiar. The differences are the ones you would
predict by now: hyphens instead of underscores in the names, `~` for
concatenation, and a block rather than a string for the code that should die.

The routines line up like this:

| `Test::More` | `Test` | Notes |
|---|---|---|
| `ok` / `nok` | `ok` / `nok` | Perl spells the negative `ok !$x` |
| `is` / `isnt` | `is` / `isnt` | compares with `eq`-like semantics |
| `is_deeply` | `is-deeply` | structural comparison |
| `like` / `unlike` | `like` / `unlike` | takes a Raku regex: `like $s, /pat/` |
| `cmp_ok` | `cmp-ok` | explicit comparator |
| `isa_ok` | `isa-ok` | type check |
| `subtest` | `subtest` | same idea, block-scoped `plan` |
| `done_testing` | `done-testing` | the alternative to declaring `plan` up front |
| `plan tests => N` | `plan N` | |
| — | `dies-ok` / `lives-ok` | no `Test::Fatal` needed |
| — | `throws-like` | asserts the *type* of the exception, per Chapter 26 |
| `diag` | `diag` | |
| `skip` / `todo` | `skip` / `todo` | |

The last two rows are the ones worth noticing. Perl reaches for `Test::Fatal` or
`Test::Exception` to assert that something dies; in Raku `dies-ok`, `lives-ok`,
and `throws-like` are built in, and `throws-like` checks the exception's *type*
against the `X::` hierarchy rather than matching its message with a regex.

Run them with `zef test .` from the distribution root, or a single file directly:

```
$ raku -I lib t/01-basic.rakutest
$ zef test .
```

## Publishing with `fez`

Uploading is deliberately undramatic. Install the uploader, register a username
once, then push from the distribution root:

```
$ zef install fez
$ fez register        # one-time: claim a username (your :auth)
$ fez login
$ fez upload          # from the directory containing META6.json
```

`fez upload` bundles the files listed by `provides` (and the rest of the
distribution), checks the `META6.json`, and publishes to the ecosystem, where
`zef` users can find it within minutes. The username you registered becomes your
`auth` string, `zef:yourname` — the authority we met in Chapter 24. Compared with
the PAUSE/CPAN upload dance, there is markedly less ceremony.

## Mixing languages: calling Perl from Raku

You do not have to port a working Perl module to use it from Raku. The
`Inline::Perl5` module embeds a real Perl interpreter in your Raku process and
bridges values across the boundary:

```
$ zef install Inline::Perl5
```

Once installed, you can load a Perl module by name and call it as though it were
Raku. Here we borrow `Text::Wrap` straight off CPAN:

```raku-static
use Text::Wrap:from<Perl5>;             # a Perl module, used from Raku

my $wrapped = Text::Wrap::wrap('', '', 'a rather long line to fold');
say $wrapped;
```

The `:from<Perl5>` adverb on `use` is the whole trick: it tells Raku to route the
load through the embedded Perl rather than the Raku ecosystem. Object-oriented
CPAN modules work too — methods, constructors and all:

```raku-static
use DBI:from<Perl5>;

my $dbh = DBI.connect('dbi:SQLite:dbname=test.db', '', '');
$dbh.do('CREATE TABLE IF NOT EXISTS t (n INT)');
```

You can also run Perl source inline, which is handy for a one-off helper without
its own file:

```raku-static
use Inline::Perl5;

my $p5 = Inline::Perl5.new;
$p5.run(q:to/PERL/);
    sub add { $_[0] + $_[1] }
    PERL
say $p5.call('add', 20, 22);    # 42
```

Values cross the bridge automatically: Raku strings and numbers arrive as Perl
scalars, Perl return values come back as Raku objects. It is not free — every
call hops between two runtimes — but for reusing a battle-tested CPAN module while
you migrate, it is often exactly the right trade.

## A teaser: calling C with `NativeCall`

When the library you want is not Perl at all but a plain C shared library, Raku
has a second bridge built into the core: `NativeCall`. There is no glue code to
compile — you declare the C function's signature in Raku and mark it `is native`:

```raku
use NativeCall;

sub strlen(Str is encoded('utf8') --> size_t) is native {*}
say strlen("hello");     # 5
```

The empty `{*}` body means "the real implementation lives in the native library".
Types such as `int32`, `num64`, `size_t`, `Pointer`, and `CArray` map Raku values
onto their C counterparts, so you can bind to `libc`, `libssl`, or your own `.so`
/ `.dylib` without writing a line of XS. This is Raku's replacement for the whole
XS toolchain — a big topic, and one worth a book of its own; here it is enough to
know the door exists and is easy to open.

Between `zef` for pure-Raku modules, `Inline::Perl5` for the CPAN back-catalogue,
and `NativeCall` for C, very little is genuinely out of reach. With the ecosystem
behind us, Part X turns to writing *robust* Raku — starting, in Chapter 26, with
how errors, exceptions, and failures work once `die`/`eval` give way to `try` and
typed exceptions.

{% include nav.html %}
