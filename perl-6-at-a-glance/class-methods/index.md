---
title: Class methods
---

{% include menu.html %}

The `method` keyword defines a method, similarly to how we define subroutines with `sub`. A method has access to all attributes of the class, both public and private.

The method itself can be private. We will return to this later after talking about inheritance.

In the following short example, two methods are created, and each of them manipulates the private `@!orders` array.

```raku
class Cafe {
    has $.name;
    has @!orders;

    method order($what) {
        @!orders.push($what);
    }

    method list-orders {
        @!orders.sort.join(', ').say;
    }
}

my $cafe = Cafe.new(
    name => "Paris"
);

$cafe.order('meat');
$cafe.order('fish');
$cafe.list-orders; # fish, meat
```

The code should be quite readable for people familiar with OOP. Just keep in mind that “everything is an object” and you may chain method calls.

```raku-static
@!orders.sort.join(', ').say;
```

Instance methods receive a special variable, `self` (having no sigil), which points to the current object. It can be used to access instance data or the class methods.

```raku-static
method order($what) {
    @!orders.push($what);
    self.list-orders;
}

method list-orders {
    say self.name;
    @!orders.sort.join(', ').say;
}
```

{% include nav.html %}
