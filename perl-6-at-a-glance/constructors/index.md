---
title: Constructors
---

{% include menu.html %}

You may have noticed in the previous examples that two different approaches to creating a typed variable were used.

The first was via an explicit call of the `new` constructor. In this case, a new instance was created.

```raku-static
my $a = A.new;
```

In the second, a variable was declared as a typed variable. Here, a container was created.

```raku-static
my A $a;
```

Creating a container means not only that the variable will be allowed to host an object of that class but also that you will still need to create that object itself.

```raku-static
my A $a = A.new;
```

Let us consider an example of a class which involves one public method and one public data field.

```raku-static
class A {
    has $.x = 42;
    method m {
        say "A.m";
    }
}
```

The internal public variable `$.x` is initialized with the constant value.

Now, let us create a scalar container for the variable of the `A` class.

```raku-static
my A $a;
```

The container is here, and we know its type, but there are no data yet. At this moment, the class method may be called. It will work, as it is a class method and does not require any instance with real data.

```raku-static
$a.m; # Prints “A.m”
```

Meanwhile, the `$.x` field is not available yet.

```raku-static
say $a.x; # Error: Cannot look up attributes in a A type object
```

We need to create an instance object by calling a constructor first.

```raku-static
my A $b = A.new;
say $b.x; # Prints 42
```

Please note that the initialization (`= 42`) only happens when a constructor is called. Prior to this, there is no object, and thus no value can be assigned to an attribute.

The `new` method is inherited from the `Mu` class. It accepts a list of the named arguments. So, this method can be used on any object with any reasonable arguments. For instance:

```raku-static
my A $c = A.new(x => 14);
say $c.x; # 14, not 42
```

Note that the name of the field (`x`) may not be quoted. An attempt of `A.new('x' => 14)` will fail because it will be interpreted as a `Pair` being passed as a positional parameter.

Alternatively, you can use the `:named(value)` format for specifying named parameters:

```raku-static
my A $c = A.new :x(14); # Or A.new(:x(14)) if you wish
say $c.x; # 14
```

For the more sophisticated constructors, the class’s own `BUILD` submethod may be defined. This method expects to get a list of the named arguments.

```raku
class A {
    # Two fields in an object.
    # One of them will be calculated in the constructor.
    has $.str;
    has $!len;

    # The constructor expects its argument named ‘str’.
    submethod BUILD(:$str) {
        # This field is being copied as is:
        $!str = $str;

        # And this field is calculated:
        $!len = $str.chars;
    }
    method dump {
        # Here, we print the current values.
        # The variables are interpolated as usual
        # but to escape an apostrophe character from
        # the variable name, a pair of braces is added.
        "{$.str}'s length is $!len.".say;
    }
}

my $a = A.new(str => "Perl");
$a.dump;
```

This programme prints the following output:

```
Perl’s length is 4.
```

{% include nav.html %}
