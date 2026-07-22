---
title: Generating random integers
---

{% include menu.html %}

You may ask, what’s the deal with it, isn’t it a routine task to call a kind of a `rand` function? Well, in some sense, yes, but you might prefer calling a

*method.*

Let’s look at the following code:

```raku
2020.rand.Int.say;
```

That’s the whole program, and it generates random numbers below 2020. It only uses method calls, chained one after another. If you have never seen Raku before, the first thing you notice here is a method called on a number. That’s not something extraordinary in this language.

Calling the `rand` method on a number is potentially a call of the method defined in the `Cool` class, which is immediately delegated to a numeric representation of the number:

```raku-static
method rand() { self.Num.rand }
```

Later in the `Num` class, a call to the underlying NQP engine happens:

```raku-static
method rand(Num:D: ) {
    nqp::p6box_n(nqp::rand_n(nqp::unbox_n(self)));
}
```

In our example, the object `2020` is an `Int`, so `rand` is dispatched directly to the method of the `Num` class.

The `rand` method returns a floating-point number, so call another method `Int` on it to get an integer.

Run the code a few times to confirm that it generates random numbers:

```
$ raku -e'2020.rand.Int.say'

$ raku -e'2020.rand.Int.say'

$ raku -e'2020.rand.Int.say'
```

If you want to understand the quality of the random number generator, dig deeper to NQP and MoarVM, and later to the backend engine of the virtual machine. To make the results repeatable (e. g., for tests), set the seed by calling `srand`:

```
$ raku -e'srand(10); 2020.rand.Int.say'

$ raku -e'srand(10); 2020.rand.Int.say'
```

Notice that the `srand` routine is a subroutine, not a method. It is also defined in the same `Num` class:

```raku-static
proto sub srand($, *%) {*}
multi sub srand(Int:D $seed --> Int:D) {
    nqp::p6box_i(nqp::srand($seed))
}
```

And if you have the chance to see the source file, you would most likely notice that there’s also a standalone subroutine for `rand`:

```raku-static
proto sub rand(*%) {*}
multi sub rand(--> Num:D) {
    nqp::p6box_n(nqp::rand_n(1e0))
}
```

You can only call it without arguments, in which case Perl 6 generates a random number between 0 and 1. If you pass the argument, you get an error explaining that a method call is preferable:

```
$ raku -e'rand(20)'
===SORRY!=== Error while compiling -e
Unsupported use of rand(N); in Raku please use N.rand for Num
or (^N).pick for Int result
at -e:1
⏏(20)
------> rand
```

{% include nav.html %}
