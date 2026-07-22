---
title: Assignment
---

{% include menu.html %}

The assignment meta-operators (`=`) use the other operators to create the constructions like `+=`, `~=`, etc. The action of the newly created operators is always equivalent to the verbose code.

If you type `$a op= $b`, then a compiler will execute the following action: `$a = $a op $b`.

That means that `$x += 2` is equivalent to `$x = $x + 2`, and `$str ~= '.'` to `$str = $str ~ '.'`.

Let us now create a new custom operator and see if the assignment meta-operator will be available for us. On purpose, I chose quite an outstanding-looking operator `^_^`:

```raku-static
sub infix:<^_^>($a, $b) {
    $a ~ '_' ~ $b
}
```

First, check the simple usage of the new operator with two operands:

```raku-static
say 4 ^_^ 5; # 4_5
```

Then, let us try the meta-operator form of it: `^_^=`:

```raku-static
my $x = 'file';

$x ^_^= 101;
say $x; # file_101
```

{% include nav.html %}
