---
title: Actions
---

{% include menu.html %}

The target file is now completely parsed. We can split it into separate statements, and then we can understand all of its parts. The only missing element is making all those parts work together to produce the result. This is what actions do in Raku.

Return to the test program in Lingua:

```raku-static
my x;
x = 42;
say x;
```

To see `42` in the console, we have to make sure there is a place where this value is stored and can be referenced by its name, `x`. In other words, we need a storage. The most obvious choice is to use a hash. Let us first make it a global variable:

```raku-static
my %var;

grammar Lingua {
    . . .
}
```

After a rule or a token is successfully matched, you can ask Raku to make something for you, namely, you can add a block of code, called action, which will be executed after the match. Inside it, you have access to the data that was just extracted.

Our first action is to create a variable when we see its declaration. Here is how you do it:

```raku-static
rule variable-declaration {
    'my' <variable-name> {
        %var{$<variable-name>} = 0;
    }
}
```

The action is placed immediately after the regex in a pair of curly braces. We know that the rule finds the substring `my x` by matching the literal `'my'` followed by a variable name, which is a named token `variable-name`. We can use this name to access the content: `$<variable-name>`. Actually, this is an object of the `Lingua` class, but we use it as a key of a hash, so it is converted to a string, and we populate the hash with a new pair `x => 0`. Thus, a variable has been created and it is initialised with a zero.

Similarly, let us create an action for the variable assignment.

```raku-static
rule assignment {
    <variable-name> '=' <value> {
        %var{~$<variable-name>} = +$<value>;
    }
}
```

Here, just to show how you could also do that, the `$<variable-name>` object is explicitly converted to a value of the `Str` data type by the `~` prefix operator. On the right side of the equals sign, another type conversion is done: the `+` operator converts `$<value>` to a number. This time it is really important to cast the value, as if you do not do that, you will save a `Lingua` object instead of a number.

And now moving on to the function call.

```raku-static
rule function-call {
    <function-name> <variable-name> {
        say %var{$<variable-name>}
            if $<function-name> eq 'say';
    }
}
```

The implementation of the `say` function is embedded in the grammar’s action. As we only have one built-in function now, the `if` clause is not really needed, but let us keep it to make the code more transparent.

How it is done so far, the three action blocks are inline. They are parts of the rule definitions. We can run the translator and see what it does. Change the main code to the following to avoid massive output:

```raku-static
my $code = 'test.lng'.IO.slurp();
my $result = Lingua.parse($code);
#say $result;
```

The code prints the following line:

```
$ raku lingua.pl 
42
```

Congratulations! The program was not only parsed but also executed. As you see, it printed the content of the variable `x`, and it is exactly what we put in it. If you dump the `%var` container (by adding `say %var;`), you’ll get `{x => 42}`.

This is our first real achievement. We managed to create an interpreter of a subset of our future Lingua language. The most exciting part here is that it is not bound to a single test program that we used before. You can create as many variables as you want, you can assign it to different values and re-assign them again. The names of the variables can be longer than a single letter. And all that magically works! Try it yourself, here’s an example of what I did:

```raku-static
my alpha;
my beta;
alpha = 100;
beta = 200;

say alpha;
say beta;

my gamma;
gamma = 33;
say gamma;

gamma = 44;
say gamma;
```

After being executed, the program printed the correct result:

```
100
200
33
44
```

You can also try assigning the value more than once:

```raku-static
my value;

value = 100;
say value;

value = 200;
say value;
```

This time, the program uses the same variable twice and stores different values in it, which you can easily confirm by running the program:

```
100
200
```

{% include nav.html %}
