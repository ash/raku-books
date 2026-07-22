---
title: ?, so
---

{% include menu.html %}

`?` is a unary operator casting the context to a Boolean one by calling the `Bool` method on an object.

```raku
say ?42; # True
```

The second form, `so`, is a unary operator with lower precedence.

```raku

say so 42;   # True
say so True; # True
say so 0.0;  # False
```

```

```

`~` casts an object to a string. Note that we are now talking about the prefix or a unary operator. If the tilde is used as an infix (see later in this chapter about what infixes are), it works as a string concatenating operator, but it still deals with strings.

```raku
my Str $a = ~42;
say $a.WHAT; # (Str)
```

In some cases, the string context can be created implicitly, for example, when you interpolate a variable inside the double quotes.

`++` is a prefix operator of increment. First, an increment is done, and then a new value is returned.

```raku
my $x = 41;
say ++$x; # 42
```

The increment operation is not limited to working only with numbers. It can also handle strings.

`my $a = 'a';`

`say ++$a; # b`

```

```

A practical example is to increment filenames containing numbers. The file extension will survive, and only the numerical part will be incremented.

```raku
my $f = "file001.txt";

++$f;
say $f; # file002.txt

++$f;
say $f; # file003.txt
```

`--` is a prefix form of decrement. It works exactly like the `++` prefix but, of course, makes the operand smaller (whether it be a string or a number).

```raku
my $x = 42;
say --$x; # 41
```

`+^` is a bitwise negation operator with two’s complement.

```raku
my $x = 10;
my $y = +^$x;
say $y; # -11 (but not -10)
```

```

```

Compare this operator with the following one.

`?^` is a logical negation operator. Please note that this is not a bitwise negation. First, the argument is converted to a Boolean value, and then the result is negated.

```raku
my $x = 10;
my $y = ?^$x;
say $y;       # False
say $y.WHAT;  # (Bool)
```

```

```

`^` is a range-creating operator or the so-called upto operator. It creates a range (which is an object of the `Range` type) from 0 up to the given value (not including it).

```raku
.print for ^5; # 01234
```

```

```

This code is equivalent to the following, where both ends of the range are explicitly specified:

```raku
.print for 0..4; # 01234
```

`|` flattens the compound objects into a list. For example, this operator should be used when you pass a list to a subroutine, which expects a list of scalars:

```raku
sub sum($a, $b) {
    $a + $b
}

my @data = (10, 20);
say sum(|@data); # 30
```

Without the `|` operator, the compiler will report an error, because the subroutine expects two scalars and cannot accept an array as an argument:

```raku-static
Calling sum(Positional) will never work with declared signature ($a, $b)
```

`temp` creates a temporary variable and restores its value at the end of the scope (like it does the `local` built-in operator in Perl 5).

```raku
my $x = 'x';
{
    temp $x = 'y';
    say $x; # y
}
say $x;     # x
```

```

```

Compare it with the following operator, `let`.

`let` is a prefix operator, which is similar to `temp`, but works correctly with exceptions. The previous value of the variable will be restored if the scope was left because of the exception.

```raku
my $var = 'a';
try {
    let $var = 'b';
    die;
}
say $var; # a
```

With a `die`, this example code will print the initial value `a`. If you comment out the call of a `die`, the effect of the assignment to `b` will stay, and the variable will contain the value `b` after the `try` block.

The `let` keyword looks similar to the declarators like `my` and `our`, but it is a prefix operator.

{% include nav.html %}
