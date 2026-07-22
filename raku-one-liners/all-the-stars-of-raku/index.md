---
title: All the stars of Raku
---

{% include menu.html %}

In this section, we go through the constructs that employ the `*` character. In Raku, you may call it a star (or asterisk if you prefer) or a whatever, depending on the context.

Raku is not a cryptic programming language. On the other side, some areas require spending time to start feeling confident in the syntax.

Let’s go through different use cases of `*`, from the simplest towards the most puzzling things such as `* ** *`.

The first two examples are trivial enough and do not require many comments.

Multiplication operator

A single star is used for multiplication. Strictly speaking, this is an infix operator `infix:<*>`, whose return value is `Numeric`.

```raku
say 20 * 18; # 360
```

Exponentiation operator

The double star `**` is the exponentiation operator. Again, this is an `in-` `fix:<**>` that returns the `Numeric` result which is the power for the given two values.

```raku
say pi ** e; # 22.4591577183611
```

A regex repetition quantifier

The same two tokens, `*` or `**`, are also used in regexes, where they mean different things. One of the features of Raku is that it can easily switch between different sub-languages inside itself. Both regexes and grammars are examples of such inner languages, where the same symbols can mean different things from what they mean in the ‘main’ language (if they have any meaning at all there).

The `*` quantifier. This syntax item works similarly to its behaviour in general Perl-compatible regexes: it allows zero or more repetitions of the atom.

```raku
my $weather = '*****';
my $snow = $weather ~~ / ('*'*) /;

say 'Snow level is ' ~ $snow.chars; # Snow level is 5
```

Of course, we also see here another usage of the same character, the `'*'` literal.

Min to max repetitions

The double `**` is a part of another quantifier that specifies the minimum and the maximum number of repetitions:

```raku
my $operator = '..';
say "'$operator' is a valid Raku operator"
    if $operator ~~ /^ '.' ** 1..3 $/;
```

In this example, it is expected that the dot is repeated one, two, or three times; not less and not more.

Let’s look a bit ahead, and use a star in the role (role as in theatre, not in Raku’s object-oriented programming) of the `Whatever` symbol:

```raku-static
say 'You are so uncertain...'
    if $phrase ~~ / '.' ** 4..* /;
```

The second end of the range is open, and the regex accepts all the phrases with more than three dots in it.

Slurpy arguments

A star before an array argument in a sub’s signature indicates a slurpy argument—the one that consumes separate scalar parameters into a single array.

```raku
list-gifts('chocolade', 'ipad', 'camelia', 'perl6');

sub list-gifts(*@items) {
    say 'Look at my gifts this year:';
    .say for @items;
}
```

Hashes also allow celebrating slurpy parameters:

```raku
dump(alpha => 'a', beta => 'b'); # Prints:
                                 # alpha = a
                                 # beta = b

sub dump(*%data) {
    for %data.kv {say "$^a = $^b"}
}
```

Notice that the code does not compile if you omit the star in the function signature, as Raku expects exactly what was announced for a subroutine:

```raku-static
Too few positionals passed; expected 1 argument but got 0
```

Slurpy-slurpy

The `**@` is also working but notice the difference when you pass arrays and lists.

With a single star:

```raku
my @a = < chocolade ipad >;
my @b = < camelia perl6 >;

all-together(@a, @b);
all-together(['chocolade', 'ipad'], ['camelia', 'perl6']);
all-together(< chocolade ipad >, < camelia perl6 >);

sub all-together(*@items) {
    .say for @items;
}
```

Currently, each gift is printed on a separate line regardless the way the argument list was passed.

With a double star:

```raku-static
keep-groupped(@a, @b);
keep-groupped(['chocolade', 'ipad'], ['camelia', 'camel']);
keep-groupped(< chocolade ipad >, < camelia camel >);

sub keep-groupped(**@items) {
    .say for @items;
}
```

This time, the `@items` array gets two elements only, reflecting the structural types of the arguments:

```
[chocolade ipad]
[camelia perl6]
```

or

```
(chocolade ipad)
(camelia perl6)
```

Twigil for dynamic scope

The `*` twigil, which introduces dynamic scope. It is easy to confuse dynamic variables with global variables, but examine the following code.

```raku
sub happy-new-year() {
    "Happy new $*year year!"
}

my $*year = 2020;
say happy-new-year();
```

If you omit the star, the code cannot be run:

```raku-static
Variable '$year' is not declared
```

The only way to make it correct is to move the definition of `$year` above the function definition. With the dynamic variable `$*year`, the place where the function is called defines the result. The `$*year` variable is not visible in the outer scope of the sub, but it is quite visible in the dynamic scope.

For a dynamic variable, it is not important whether you assign a new value to an existing variable or create a new one:

```raku
sub happy-new-year() {
    "Happy new $*year year!"
}

my $*year = 2018;

say happy-new-year();     # 2018

{
    $*year = 2019;        # New value
    say happy-new-year(); # 2019
}

{
    my $*year = 2020;     # New variable
    say happy-new-year(); # 2020
}

say happy-new-year();     # 2019
```

Compiler variables

A number of dynamic pseudo-constants come with Raku, for example:

```raku-local
say @*ARGS;      # Prints command-line arguments
say %*ENV<HOME>; # Prints home directory
```

All methods with the given name

The `.*` postfix pseudo-operator calls all the methods with the given name, which can be found for the given object, and returns a list of results. In the trivial case you get a scholastically absurd code:

```
> pi.gist.say
3.141592653589793

> pi.*gist.say
(3.141592653589793 3.141592653589793e0)
```

The real power of the `.*` postfix comes with inheritance. It helps to reveal the truth sometimes:

```raku-nobrowser
class Present {
    method giver() {
        'parents'
    }
}

class ChristmasPresent is Present {
    method giver() {
        'Santa Claus'
    }
}

my ChristmasPresent $present;

$present.giver.say;             # Santa Claus
$present.*giver.join(', ').say; # Santa Claus, parents
```

Just a star but what a difference!

* * * Now, to the most mysterious part of the star corner of Raku. The next two concepts, the `Whatever` and the `WhateverCode` classes, are easy to mix up with each other. Let’s try to do it right.

Whatever

A single `*` can represent `Whatever`. `Whatever` is a predefined class which introduces some prescribed behaviour in a few useful cases.

For example, in ranges and sequences, the final `*` means infinity. We’ve seen such examples already. Here is another one:

```raku-static
.say for 1 .. *;
```

This one-liner has a really high energy conversion efficiency as it generates an infinite list of increasing integers. Press `Ctrl+C` when you are ready to move on.

The range `1 .. *` is the same as `1 .. Inf`.

Returning to our more practical problems, let’s create our own class that makes use of the whatever symbol `*`. Here is a simple example of a class with a multi-method taking either an `Int` value or a `Whatever`.

```raku-static
class N {
    multi method display(Int $n) {
        say $n;
    }

    multi method display(Whatever) {
        say 2000 + 100.rand.Int;
    }
}
```

In the first case, the method simply prints the value. The second method prints a random number between 2000 and 2100 instead. As the only argument of the second method is `Whatever`, variable name is not required in the signature.

Here is how you use the class:

```raku-static
my $n = N.new;

$n.display(2020);
$n.display(*);
```

The first call echoes its argument, while the second one prints something random.

The `Whatever` symbol can be held as a bare `Whatever`. Say, you create an `echo` function and pass the `*` to it:

```raku
sub echo($x) {
    say $x;
}

echo(2018); # 2018
echo(*);    # *
```

This time, no magic happens, the program prints a star.

And now we are at a point where a tiny thing changes a lot.

WhateverCode

Finally, it’s time to talk about `WhateverCode`.

Take an array and print the last element of it. You can’t do it by typing something like `@a[-1]`, as it generates an error:

```raku-static
Unsupported use of a negative -1 subscript
to index from the end; in Raku please
use a function such as *-1
```

The compiler suggests using `a function such as *-1`. Is it a function? Yes, more precisely, a `WhateverCode` block:

```raku
say (*-1).WHAT; # (WhateverCode)
```

Now, print the second half of an array:

```raku
my @a = < one two three four five six >;
say @a[3..*]; # (four five six)
```

An array is indexed with the range `3..*`. The `Whatever` star as the right end of the range instructs to take all the rest from the array. The type of `3..*` is a `Range`:

```raku
say (3..*).WHAT; # (Range)
```

Finally, take one element less. We’ve already seen that to specify the last element, a function such as `*-1` must be used. The same can be done at the right end of a range:

```raku-static
say @a[3 .. *-2]; # (four five)
```

At this point, the so-called Whatever-currying happens, and a `Range` becomes a `WhateverCode`:

```raku
say (3 .. *-2).WHAT; # (WhateverCode)
```

`WhateverCode` is a built-in class name; it can easily be used for method dispatching. Let’s update the code from the previous section and add a method variant that expects a `WhateverCode` argument:

```raku-static
class N {
    multi method display(Int $n) {
        say $n;
    }
    multi method display(Whatever) {
        say 2000 + 100.rand.Int;
    }

    multi method display(WhateverCode $code) {
        say $code(2000 + 100.rand.Int);
    }
}
```

Now, the star in the argument list falls into either `display(Whatever)` or

```raku-static
display(WhateverCode):

N.display(2018);     # display(Int $n)
N.display(*);        # display(Whatever)
N.display(* / 2);    # display(WhateverCode $code)
N.display(* - 1000); # display(WhateverCode $code)
```

Once again, look at the signature of the `display` method:

```raku-static
multi method display(WhateverCode $code)
```

The `$code` argument is used as a function reference inside the method:

```raku-static
say $code(2000 + 100.rand.Int);
```

The function takes an argument but where is it going to? Or, in other words, what and where is the function body? We called the method as `N.display(*` `/ 2)` or `N.display(* - 1000)`. The answer is that both `* / 2` and `* - 1000` are functions! Remember the compiler’s hint about using `a function such`

```
as *-1?
```

The star here becomes the first function argument, and thus `* / 2` is equivalent to `{$^a / 2}`, while `* - 1000` is equivalent to `{$^a - 1000}`.

Does it mean that `$^b` can be used next to `$^a`? Sure! Make a `WhateverCode` block accept two arguments. How do you indicate the second of them? Not a surprise, with another star! Let us add the fourth variant of the `display` method to our class:

```raku-static
multi method display(WhateverCode $code
                     where {$code.arity == 2}) {
    say $code(2000, 100.rand.Int);
}
```

Here, the `where` block is used to narrow the dispatching down to select only those `WhateverCode` blocks that have two arguments. Having this done, two snowflakes are allowed in the method call:

```raku-static
N.display( * + * );
N.display( * - * );
```

The calls define the function `$code` that is used to calculate the result. So, the actual operation behind `N.display( * + * )` is the following: `2000 +`

```
100.rand.Int.
```

Need more snow? Add more stars:

```raku-static
N.display( * * * );
N.display( * ** * );
```

Similarly, the actual calculations inside are:

```
2000 * 100.rand.Int
```

and

```
2000 ** 100.rand.Int
```

Congratulations! You can now parse the `* ** *` construct as effortlessly as the compiler does it.

Homework

Let’s make an exercise and answer the following question: What does each star mean in the following code?

```raku-nobrowser
my @n = ((0, 1, * + * ... *).grep: *.is-prime).map: * * * * *;
.say for @n[^5];
```

D’oh. I suggest we start transforming the code to get rid of all the stars and to use a different syntax.

The `*` after the sequence operator `...` means generating the sequence infinitely, so replace it with `Inf`:

```raku-static
((0, 1, * + * ... Inf).grep: *.is-prime).map: * * * * *
```

The two stars `* + *` in the generator function can be replaced with a lambda function with two explicit arguments:

```raku-static
((0, 1, -> $x, $y {$x + $y} ... Inf).grep:
    *.is-prime).map: * * * * *
```

Now, a simple syntax alternation. Replace the `.grep:` with a method call with parentheses. Its argument `*.is-prime` becomes a code block, and the star is replaced with the default variable `$_`. Notice that no curly braces were needed while the code was using a `*`:

```raku-static
(0, 1, -> $x, $y {$x + $y} ... Inf).grep({
    $_.is-prime
}).map: * * * * *
```

Finally, the same trick for `.map:` but this time there are three arguments for this method, thus, you can write `{$^a * $^b * $^c}` instead of `* * * * *`, and here’s the new layout of the complete program:

```raku-nobrowser
my @n = (0, 1, -> $x, $y {$x + $y} ... Inf).grep({
        $_.is-prime
    }).map({
        $^a * $^b * $^c
    });
.say for @n[^5];
```

Now it is obvious that the code prints five products of the groups of three prime Fibonacci numbers.

Additional assignments

In textbooks, the most challenging tasks are marked with a *. Here are a couple of them for you to solve yourself.

1. What is the difference between `chdir('/')` and `&*chdir('/')`? 2. Explain the following code and modify it to demonstrate its advantages: `.say for 1...**`.

{% include nav.html %}
