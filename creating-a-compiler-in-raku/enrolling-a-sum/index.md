---
title: Enrolling a sum
---

{% include menu.html %}

Let us first take a test expression  and create a working prototype of the calculator for it. The grammar only needs to parse integers and a literal plus sign:

```raku-static
grammar Calculator {
    rule TOP {
        <number> '+' <number>
    }

    token number {
        \d+
    }
}
```

The actions are straightforward too. We are using the AST attributes to keep the values:

```raku-static
class CalculatorActions {
    method TOP($/) {
        $/.make($<number>[0].made + $<number>[1].made);
    }

    method number($/) {
        $/.make(+$/);
    }
}
```

Everything is ready to run the test and confirm that it prints 7 indeed:

```raku-static
Calculator.parse('3 + 4',
                 :actions(CalculatorActions)).made.say;
```

That was not difficult at all. The code works with other integer numbers with no changes in the grammar or actions, but our next goal is to teach it handling a minus sign for subtraction.

A first approach can be introducing different kind of statements at the very top of the grammar:

```raku-static
rule TOP {
    | <addition>
    | <subtraction>
}

rule addition {
    <number> '+' <number>
}

rule subtraction {
    <number> '-' <number>
}
```

Accordingly, let’s create separate action methods for both addition and subtraction:

```raku-static
method TOP($/) {
    $/.make($<addition> ?? 
            $<addition>.made !! $<subtraction>.made);        
}

method addition($/) {
    $/.make($<number>[0].made + $<number>[1].made);
}

method subtraction($/) {
    $/.make($<number>[0].made - $<number>[1].made);
}
```

Now, test the second case:

```raku-static
my @cases = '3 + 4', '3 - 4';
for @cases -> $test {
    say "$test = " ~ Calculator.parse($test,
                     :actions(CalculatorActions)).made;
}
```

OK, everything works as expected:

```
3 + 4 = 7
3 - 4 = -1
```

It all works but you should not be satisfied with the solution. It is much better to merge both addition and subtraction down to a single rule:

```raku-static
rule TOP {
    <number> <op> <number>
}

token op {
    '+' | '-'
}
```

The grammar became simpler, and the operator is explicitly defined in its own token that matches either plus or minus.

Similarly, the `addition` and `subtraction` action methods can be replaced with a generic solution:

```raku-static
method TOP($/) {
    if $<op> eq '+' {
        $/.make($<number>[0].made + $<number>[1].made);
    }
    else {
        $/.make($<number>[0].made - $<number>[1].made);
    }
}
```

And that’s it. The grammar now treats both tests as a valid expression and makes correct calculations based on the value of `$<op>`. As it is used with the `eq` operator that expects strings, it is implicitly translated to a string and no separate action to handle the `op` token is not needed.

{% include nav.html %}
