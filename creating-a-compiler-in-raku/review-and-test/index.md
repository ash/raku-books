---
title: Review and test
---

{% include menu.html %}

Let us take a look at the current state of the Lingua language. We made a big work and implemented support for numbers, strings, arrays and hashes. It is possible to change the content of the variables and print their values. Let us make another small step to allow variables to index arrays and be the keys of hashes.

```raku-static
rule array-index {
    '[' [ <integer> | <variable-name> ] ']'
}

rule hash-index {
    '{' [ <string> | <variable-name> ] '}'
}
```

The corresponding actions can be transformed to pairs of trivial multi-methods:

```raku-static
multi method array-index($/ where !$<variable-name>) {
    $/.make(+$<integer>);
}

multi method array-index($/ where $<variable-name>) {
    $/.make(%!var{$<variable-name>});
}

multi method hash-index($/ where !$<variable-name>) {
    $/.make($<string>.made);
}

multi method hash-index($/ where $<variable-name>) {
    $/.make(%!var{$<variable-name>});
}
```

Refer to the repository to check if you’ve got the correct files and if so, you will be able to run the following test program that uses most of the features that are implemented at this moment.

```raku-static
# Illustrating the Pythagorean theorem
my a = 3;
my b = 4;
my c = 5;
my left = a**2 + b**2;
my right = c**2;
say "The hypotenuse of a rectangle triangle with the 
sides $a and $b is indeed $c, as $left = $right.";

/* Using floating-point numbers for 
computing the length of a circle */
my pi = 3.1415926;
my R = 7;
my c = 2 * pi * R;
say "The length of a circle of radius $R is $c.";

# A list of prime numbers
my n = 5;
my data[] = 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31;
my nth = data[n];
say "$n th prime number is $nth.";

# Demonstrating the use of hashes
my countries{} = 
    "France": "Paris", "Germany": "Berlin", "Italy": "Rome";
my country = "Italy";
my city = countries{country};
say "$city is the capital of $country.";
```

This program prints the following result.

```
$ ./lingua test22.lng 
The hypotenuse of a rectangle triangle with the 
sides 3 and 4 is indeed 5, as 25 = 25.
The length of a circle of radius 7 is 43.9822964.
5 th prime number is 13.
Rome is the capital of Italy.
OK
```

It is quite fascinating to see that the interpreter understands the program that never existed before. You wrote it and you can make lots of changes in it, and the program will still show the results you expect from it.

In the next chapters, we will work on more complex elements of the language.

{% include nav.html %}
