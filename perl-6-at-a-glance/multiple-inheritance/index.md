---
title: Multiple inheritance
---

{% include menu.html %}

When more than one class is mentioned in the list of base classes, we have multiple inheritance.

```raku
class A {
    method a {
        say "A.a"
    }
}

class B {
    method b {
        say "B.b";
    }
}

class C is A is B {
}

my $c = C.new;
$c.a;
$c.b;
```

With multiple inheritance, method resolution order is more important, as different base classes may have methods with the same name, or, for example, the two base classes have another common parent. This is why you should know the order of the base class now.

```raku-static
class A {
    method meth {
        say "A.meth"
    }
}

class B {
    method meth {
        say "B.meth";
    }
}
```

```raku-static
class C is A is B {
}

class D is B is A {
}
```

Here, the method named `meth` exists in both parent classes `A` and `B`, thus calling it on variables of the types `C` and `D` will be resolved differently.

```raku-static
my $c = C.new;
$c.meth; # A.meth

my $d = D.new;
$d.meth; # B.meth
```

This behaviour is confirmed by the method resolution order list, which is actually used by the compiler.

```raku-static
$c.^mro.say; # ((C) (A) (B) (Any) (Mu))
$d.^mro.say; # ((D) (B) (A) (Any) (Mu))
```

{% include nav.html %}
