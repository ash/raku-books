---
title: Private (closed) methods
---

{% include menu.html %}

Now, after we have discussed inheritance, let us return to the private (or closed) methods. These methods may only be used within the class itself. Thus, you cannot call them from the programme that uses an instance of the class. Nor are they accessible in the derived classes. An exclamation mark is used to denote a private method.

The following example demonstrates the usage of a private method of a class. The comments in the code will help you to understand how it works.

```raku
class A {
    # Method is only available within A
    method !private {
        say "A.private";
    }

    # Public method calling a private method
    method public {
        # You cannot avoid self here.
        # Consider the '!' as a separator like '.'
        self!private;
    }
}

class B is A {
    method method {
        # Again self, but this the '.' this time.
        # This is a public method.
        self.public;

        # This will be a compile-time error.
        # self!private;
    }
}

my $b = B.new;
$b.method; # A.private
```

The exclamation mark is actually part of the method name. So you can have both `method meth` and `method !meth` in the same class. To access them, use `self.meth` and `self!meth`, respectively:

```raku-nobrowser
class C {
    method meth  {say 'meth' }
    method !meth {say '!meth'}
    method demo {
        self.meth;
        self!meth;
    }
}

my $c = C.new;
$c.demo; # Prints both meth and !meth
```

{% include nav.html %}
