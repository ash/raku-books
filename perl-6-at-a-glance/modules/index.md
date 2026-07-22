---
title: Modules
---

{% include menu.html %}

Basically, the Perl 6 modules are the files on disk containing the Perl 6 code. Modules are kept in files with the `.pm` extension. The disk hierarchy reflects the namespace enclosure, which means that a module named `X::Y` corresponds to the file `X/Y.pm`, which will be searched for in one of the predefined catalogues or in the location specified by the `-I` command line option. Perl 6 has more sophisticated rules for where and how to search for the real files (e. g., it can distinguish between different versions of the same module), but let us skip that for now.

The keyword `module` declares a module. The name of the module is given after the keyword. There are two methods of scoping the module. Either it can be a bare directive in the beginning of a file, or the whole module can be scoped in the code block within the pair of braces.

In the first option, the rest of the file is the module definition (note the presence of the `unit` keyword).

```raku-static
unit module X;

sub x() {
    say "X::x()";
}
```

In the second option, the code looks similar to the way you declare classes (more on classes in Chapter 4).

```raku-static
module X {
    sub x() {
        say "X::x()";
    }
}
```

```

```

The `my` and `our` variables, as well as `sub`s, which are defined in the module, are not visible outside of its scope by default. To export a name, the `is export` trait is required.

```raku-static
unit module X;

sub x() is export {
    say "X::x()";
}
```

This is all you need to do to be able to call the `x()` sub in the programme using your module.

To use a module in your code, use the keyword `use`.

An example. Let us first create the module `Greet` and save it in the file named `Greet.pm`.

```raku-static
unit module Greet;

sub hey($name) is export {
    say "Hey, $name!";
}
```

```

```

Then, let us use this module in our programme by saying `use Greet`.

```raku-static
use Greet;

hey("you"); # Hey, you!
```

Module names can be more complicated. With `is export`, all the exported names will be available in the current scope after the module is `use`d.

In the following example, the module `Greet::Polite` sits in the `Greet/Polite.pm` file.

```raku-static
module Greet::Polite {
    sub hello($name) is export {
        say "Hello, $name!";
    }
}
```

```

```

The programme uses both of these modules and can access all the exported subs.

```raku-static
use Greet;
use Greet::Polite;

hey("you");     # a sub from Greet
hello("Mr. X"); # from Greet::Polite
```

```

```

The `use` keyword automatically imports the names from modules. When a module is defined in the current file in the lexical scope (please note that the module can be declared as local with `my module`), no import will be done by default. In this case, importing the names should be done explicitly with the `import` keyword.

```raku-nobrowser
my module M {
    sub f($x) is export {
        return $x;
    }
}

import M;

say f(42);
```

The `f` name will only be available for use after it is imported. Again, only the names marked as `is export` are exported.

As import happens in the compile-time, the `import` instruction itself can be located even after some names from the module are used.

```raku-nobrowser
my module M {
    sub f($x) is export {
        return $x;
    }
}

say f(1); # 1
import M;
say f(2); # 2
```

```

```

To just load a module and do no exports, use the `need` keyword.

Let us create a module named `N`, which contains the sub `n()`. This time, the sub is declared as `our` but with no `is export`.

```raku-static
unit module N;

our sub n() {
    say "N::n()";
}
```

Then you `need` a module and may use its methods using the fully qualified names.

```raku-static
need N;

N::n();
```

The sequence of the two instructions: `need M; import M;` (now `import` should always come after the `need`) is equivalent to a single `use M;` statement.

The `require` keyword loads a module at a runtime unlike the `use`, which loads it at the compile-time.

For example, here is a module with a single sub, which returns the sum of its arguments.

```raku-static
unit module Math;

our sub sum(*@a) {
    return [+] @a;
}
```

(The star in `*@a` is required to tell Perl to pack all the arguments into a single array so that we can call the sub as `sum(1, 2, 3)`. With no `*`, a syntax error will occur, as the sub expects an array but not three scalars.)

Now, `require` the module and use its sub.

```raku-static
require Math;

say Math::sum(24..42); # 627
```

```

```

Before the `import Math` instruction, the programme will not be able to call `Math::sum()` because the name is not yet known. A single `import Math;` will not help as the import happens at compile-time when the module is not loaded yet.

{% include nav.html %}
