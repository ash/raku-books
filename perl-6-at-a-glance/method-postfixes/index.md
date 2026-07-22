---
title: Method postfixes
---

{% include menu.html %}

There are a few syntactical elements in Perl 6, which start with a dot. These operators might look like a postfix operator, but they all are the forms of the calling a method on an object. Unlike Perl 5, the dot operator does not do any string concatenation.

`.method` calls a `method` on a variable. This works with both real objects and with those variables, which are not instances of any class, for example, built-in types like integers.

```raku
say "0.0".Numeric; # 0
say 42.Bool;       # True

class C {
    method m() {say "m()"}
}
my $c = C.new;
$c.m(); # m()
```

```

```

`.=method` is a mutating call of the `method` on an object. The call `$x.=method` does the same as the more verbose assignment `$x = $x.method`.

In the following example, the `$o` container initially holds an object of the `C` class, but after `$o.=m()`, the value will be replaced with an instance of the `D` class.

```raku-nobrowser
class D { }

class C {
    method m() {
        return D.new;
    }
}

my $o = C.new;
say $o.WHAT;  # (C)

$o.=m();
say $o.WHAT;  # (D)
```

```

```

`.^method` calls a `method` on the object’s metaobject. A metaobject is an instance of the `HOW` class and contains some additional information about the object. The following two operations, applied to the `$i` variable, are equivalent and print the list of the methods available for the `Int` variables.

```raku-nobrowser
my Int $i;
say $i.^methods();
say $i.HOW.methods($i);
```

```

```

`.?method` calls a method if it is defined. If the object does not have a method with the given name, `Nil` is returned.

```raku-nobrowser
class C {
    method m() {'m'}
}

my $c = C.new();
say $c.?m(); # m
say $c.?n(); # Nil
```

```

```

`.+method` makes an attempt to call all the methods with the given name on an object. This may be used, for example, when an instance is a part of the hierarchy of objects and its parent also has a method with the same name. More on the classes and class hierarchy in Chapter 4.

```raku-nobrowser
class A {
    method m($x) {"A::m($x)"}
}
class B is A {
    method m($x) {"B::m($x)"}
}

my $o = B.new;
my @a = $o.+m(7);
say @a; # Prints [B::m(7) A::m(7)]
```

Here, the `$o` object has the `m` method in both its own class `B` and in its parent class `A`. The `$o.+m(7)` calls both of the methods and puts their results in a list.

If the method is not defined, an exception will be thrown.

`.*method` calls all the methods with the given `method` name and returns a parcel with the results. If the method is not defined, an empty list is returned. In the rest, it behaves like the `.+` operator.

{% include nav.html %}
