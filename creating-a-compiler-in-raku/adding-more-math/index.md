---
title: Adding more math
---

{% include menu.html %}

The calculator is now only working with addition and subtraction. The good part is that it can compute long expressions that contain more than two numbers. It is a right time to teach it handling multiplication and division.

It would be naïve to just extend the `op` token to create more candidates of the `operation` function:

```raku-static
grammar Calculator {
    . . .

    token op {
        '+' | '-' | '*' | '/'
    }

    . . .
}

class CalculatorActions {
    . . .
    
    multi sub operation('*', $a is rw, $b) {
        $a *= $b
    }

    multi sub operation('/', $a is rw, $b) {
        $a /= $b
    }

    . . .
}
```

This grammar parses and even evaluates all the possible expressions with all four arithmetic operations, but it does not follow the standard precedence rules:

```
3 * 4 = 12
100 / 25 = 4
1 + 2 * 3 = 9
```

One of the possible solutions is to use a stack to perform the calculations. You scan the input string from left to right and keep applying the next operator to the numbers until you meet an operator with higher precedence. In this case, you put the current result to the stack and continue with a new series of calculations until you reach an operator with lower precedence. Then you try to pop the numbers and the operators from the stack and reduce it until it is fully consumed. This is a good exercise to make at home, but we’ll choose a simple way.

Another method of handling the precedence of arithmetic operations is to change the grammar in such a way so that it extracts multiplication and division operations first, and then passes the result to the remaining additions and subtractions.

In the next fragment, the new grammar is shown:

```raku-static
grammar Calculator {
    rule TOP {
        <term>* %% <op1>
    }

    rule term {
        <factor>* %% <op2>
    }

    token op1 {
        '+' | '-'
    }

    token op2 {
        '*' | '/'
    }

    rule factor {
        <number>        
    }

    token number {
        \d+
    }
}
```

Let us examine it. First of all, notice how we changed the `TOP` rule comparing to the previous variant. Repetition is much simpler to express with the `%%` operator. Compare the two regexes:

```
<number> [<op> <number> <ws>]*
```

and

```raku-static
<number>* %% <op>
```

The second change is introducing two operator sets: `op1` for  and  and `op2` for  and . Operators in `op1` have lower precedence, and they appear in the top-level rule of the grammar. In other words, we think of an input expression as of a sum that only contains numbers that you add or subtract.

The multiplication and division operators have higher precedence, and you should treat their results as a whole on the top level. This is why instead of matching numbers, the `term` token is introduced. It can be a number in the end, but it is first of all a series of factors separated by `*` or `/`. A factor is basically a number in our case. I intentionally added a separate proxy rule to keep the names terms and factors, which you will often see in compiler-related literature.

In the actions class, we have the four `operation` functions already, all we need is to add a trivial method for factors and create the action for terms.

```raku-static
class CalculatorActions {
    . . .

    method TOP($/) {
        $/.make(process($<term>, $<op1>));
    }

    method term($/) {
        $/.make(process($<factor>, $<op2>));
    }

    sub process(@data, @ops) {
        my @nums = @data.map: *.made;
        my $result = @nums.shift;

        operation(~@ops.shift, $result, @nums.shift)
            while @nums;

        return $result;
    }

    method factor($/) {
        $/.make($<number>.made);
    }

    method number($/) {
        $/.make(+$/);
    }
}
```

As you can see, both `TOP` and `term` are implementing the same algorithm; they just deal with different parts of the grammar.

{% include nav.html %}
