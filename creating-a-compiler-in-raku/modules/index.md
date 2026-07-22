---
title: Modules
---

{% include menu.html %}

The first simple translator is ready but let us spend a few more minutes to make its code a bit more structured and a bit faster.

First of all, the inline actions can be assembled in a separate class. In our current implementation, all the actions are the one-liners, but in more advanced compilers it will not be like that. In Raku, it is very easy to express the relations between the actions and the rules of the grammar. Just use the same names when creating the methods of the actions class. Look at the following code and you will understand it instantly.

```raku-static
class LinguaActions {
    method variable-declaration($/) {
        %var{$<variable-name>} = 0;
    }

    method assignment($/) {
        %var{~$<variable-name>} = +$<value>;
    }

    method function-call($/) {
        say %var{$<variable-name>}
            if $<function-name> eq 'say';
    }   
}
```

All these methods take a single argument. Its name can be whatever you want but for convenience it is wise to call it `$/`, as in this case you can later use shortcuts like `$<value>` instead of `$/<value>`. In the case you name it, say, `$arg`, you’ll have to type more characters to access its parts: `$arg<value>`. Also, don’t forget to remove the code blocks from the grammar class together with their surrounding curly braces.

To use the actions class with the grammar, pass it as a named argument to the `parse` method:

```raku-static
Lingua.parse($code, :actions(LinguaActions));
```

It is also a good practice to extract the classes and save them in separate files. For example, the grammar goes to `Lingua.pm`, and actions (together with the `%var` hash, which is currently a module’s global variable) to `LinguaActions.pm`. Let us also keep the module files in a separate directory named `lib` — a common convention in the Raku world. The `use lib` pragma at the top of the program tells the compiler where to search for the modules. The whole translator code is shortened then to the following:

```raku-static
use lib 'lib';
use Lingua;
use LinguaActions;

my $code = 'test.lng'.IO.slurp();
Lingua.parse($code, :actions(LinguaActions));
```

This step not only helps to logically organise the code but also increments the speed of translation. If the Raku compiler is able to cache the compiled modules, then you will only need to compile them once. Every next run is faster, because a pre-compiled version of the module is used.

{% include nav.html %}
