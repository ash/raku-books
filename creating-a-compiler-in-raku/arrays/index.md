---
title: Arrays
---

{% include menu.html %}

Arrays are collections of elements, which use their common variable name and are accessible via integer indices. Let us introduce the following syntax for array declaration:

```raku-static
my data[];
```

It uses the same `my` keyword as for declaring scalar variables and has two square brackets after the name. The `variable-declaration` grammar rule can now be split in two parts, one for arrays and one for scalars:

```raku-static
rule variable-declaration {
    'my' [
        | <array-declaration>
        | <scalar-declaration>
    ]
}
```

Arrays go first here, as their definition contains extra characters after the variable name and can be caught earlier.

The previous rule for (scalar) variable declaration migrates to a separate rule:

```raku-static
rule array-declaration {
    <variable-name> '[' ']'
}

rule scalar-declaration {
    <variable-name> [ '=' <value> ]?
}
```

The new `array-declaration` rule requires a pair of square brackets and does not yet include an initialiser part.

In the actions, we have now to distinguish between arrays and scalars too, and we can do it by checking the presence of the `$<array-declaration>` match object, for example.

```raku-static
method variable-declaration($/) {
    if $<scalar-declaration> {
        %!var{$<scalar-declaration><variable-name>} =
            $<scalar-declaration><value> ??
            $<scalar-declaration><value>.made !! 0;
    }
    elsif $<array-declaration> {
        %!var{$<array-declaration><variable-name>} = $[];
    }
}
```

It works but it looks too overloaded with nested match object keys. In fact, there is no need for doing that, because individual actions can be created for each case.

```raku-static
method scalar-declaration($/) {
    %!var{$<variable-name>} = $<value> ?? $<value>.made !! 0;
}

method array-declaration($/) {
    %!var{$<variable-name>} = $[];
}
```

With this change, the `variable-declaration` method is not needed anymore and can be removed from the `LinguaActions` class.

You can temporarily replace it with the following code just to see how the parser works with arrays:

```raku-static
method variable-declaration($/) {
    dd %!var;
}
```

The method displays what the variable storage contains after each variable declaration. Let us test this in action:

```raku-static
my x = 3;
say x;

my data[];
```

This program successfully compiles, and you can see how the `%!var` hash changes:

```raku-static
Hash %!var = {:x(3)}
3
Hash %!var = {:data($[]), :x(3)}
OK
```

{% include nav.html %}
