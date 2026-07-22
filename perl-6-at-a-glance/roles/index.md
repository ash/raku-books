---
title: Roles
---

{% include menu.html %}

Apart from the bare classes, the Perl 6 language allows roles. These are what are sometimes called interfaces in other object-oriented languages. Both the methods and the data, which are defined in a role, are available for “addition” (or mixing-in) to a new class with the help of the `does` keyword.

A role looks like a base class that appends its methods and data to generate a new type. The difference between prepending a role and deriving a class from a base class is that with a role, you do not create any inheritance. Instead, all the fields from the role become the fields of an existing class. In other words, classes are the is a characteristic of an object, while roles are the does traits. With roles, name conflicts will be found at compile time; there is no need to traverse the method resolution order paths.

The following example defines a role, which is later used to create two classes; we could achieve the same with bare inheritance, though:

```raku-static
# The role of the catering place is to take orders 
# (via the order method), to count the total amount 
# of the order (method calc) and issuing a bill (method bill).
role FoodService {
    has @!orders;

    method order($price) {
        @!orders.push($price);
    }

    method calc {
        # [+] is a hyperoperator (hyperop) connecting all the
        # elements of an array.
        # It means that [+] @a is equivalent to
        # @a[0] + @a[1] + ... + @a[N].
        return [+] @!orders;
    }
```

```raku-static
    method bill {
        # Order's total is still a sum of the orders.
        return self.calc;
    }
}

# Launching a cafe. A cafe is a catering place.
class Cafe does FoodService {
    method bill {
        # But with a small surcharge.
        return self.calc * 1.1;
    }
}

# And now a restaurant.
class Restaurant does FoodService {
    method bill {
        # First, let the customer wait some time.
        sleep 10.rand;

        # Second, increase the prices even more.
        return self.calc * 1.3;
    }
}
```

Let us try that in action. First, the cafe.

```raku-static

my $cafe = Cafe.new;
$cafe.order(10);
$cafe.order(20);
say $cafe.bill; # Immediate 33
```

Then, the restaurant. (Note that this code will have a delay because of the class definition).

```raku-static
my $restaurant = Restaurant.new;
$restaurant.order(100);
$restaurant.order(200);
say $restaurant.bill; # 390 after some unpredictable delay
```

`Roles can be used for defining and API and forcing the presence of a method in a class that uses a role. For example, let’s create a role named Liquid`, `which requires that the flows method must be implemented.`

```raku-static

role Liquid {
    method flows {...}
}

class Water does Liquid {
}

It is not possible to run this programme as it generates a compile-time error:

Method 'flows' must be implemented by Water because it is required by a role
```

Note that the ellipsis `...` is a valid Perl 6 construction that is used to create forward declarations.

{% include nav.html %}
