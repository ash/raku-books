---
title: Inheritance
---

{% include menu.html %}

Inheritance is easy. Just say `is Baseclass` when declaring a class. Having said that, your class will be derived from the base class.

```raku-static
class A {
    method x {
        say "A.x"
    }
    method y {
        say "A.y"
    }
}

class B is A {
    method x {
        say "B.x"
    }
}
```

The further usage of the inherited classes is straightforward.

```raku-static
my $a = A.new;
$a.x; # A.x
$a.y; # A.y

my $b = B.new;
$b.x; # B.x
$b.y; # A.y
```

It is important that the result of the method search does not depend on which type was used to declare a variable. Perl 6 always will first use the methods belonging to the class of the variable, which is currently stored in the variable container. For example, return to the previous example and declare the variable `$b` to be one of type `A`, but still create an instance of `B` with `B.new`. Even in that case, calling `$b.x` will still lead to the method defined in the derived class.

```raku-static
my A $b = B.new;
$b.x; # B.x
$b.y; # A.y
```

Meta-methods (which also are available for every object without writing any code) provide information about the class details. In particular, to see the exact order in which method resolution will be executed, call the `.^mro` metamethod.

```raku-static
say $b.^mro;
```

In our example, the following order will be printed.

((B) (A) (Any) (Mu))

Of course, you may call the `.^mro` method on any other variable or object in a programme, regardless of whether it is an instance of the user-defined class, a simple variable, or a constant. Just get an idea of how this is implemented internally.

```
$ perl6 -e'42.^mro.say'
```

((Int) (Cool) (Any) (Mu))

{% include nav.html %}
