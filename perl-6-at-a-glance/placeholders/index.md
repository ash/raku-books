---
title: Placeholders
---

{% include menu.html %}

When an anonymous code block is created, declaring a list of arguments is not mandatory even when a block takes an argument. To let this happen, Perl 6 uses special variable containers, which come with the `^` twigil. This is similar to the predefined variables `$a` and `$b` in Perl 5.

In the case of more than one argument, their actual order corresponds to the alphabetical order of the names of the `^`-ed variables.

```raku
my $pow = {$^x ** $^y};
say $pow(3, 4); # 81
```

```

```

The values `3` and `4`, which were passed in the function call, will land in its variables `$^x` and `$^y`, respectively.

Now, let us go back to the loop example from the previous section and rewrite it in the form with no arguments (and thus, no arrow).

```raku
for 0..9 {
    say "$^n2, $^n1";
}
```

Note that the code block starts immediately after the list, and there is no arrow. There are two loop variables, `$^n1` and `$^n2`, and they are not in alphabetical order in the code. Still, they get the values as though they were mentioned in the function signature as `($n1, $n2)`.

Finally, the placeholders may be named parameters. The difference is in the twigil. To make the placeholder named, use the colon `:`.

```raku
my $pow = {$:base ** $:exp};
say $pow(:base(25), :exp(2)); # 625
```

With the named placeholders, the alphabetical order is of no importance anymore. The following call gives us the same result.

```raku-static
say $pow(:exp(2), :base(25)); # 625
```

Keep in mind that using named placeholders is just a different way of specifying a signature to the block, and you cannot have both.

The following example demonstrates that you cannot use a placeholder with the name of the already existing parameter:

```raku-static
sub f($a) {
    # say $^a; # Error: Redeclaration of symbol '$^a'
               # as a placeholder parameter
}
```

Neither you can use any other placeholder names if the signature of the sub is already defined:

```raku-static
sub f($a) {
    say $^b; # Placeholder variable '$^b' cannot
             # override existing signature
}
```

{% include nav.html %}
