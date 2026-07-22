---
title: The EVAL routine
---

{% include menu.html %}

The `EVAL` routine compiles and executes the code that it gets as an argument.

Let us start with evaluating a simple program:

```raku
EVAL('say 123');
```

This program says `123`, there’s no surprise here.

There are, though, more complicated cases. What, do you think, does the following program print?

```raku
EVAL('say {456}');
```

I guess it prints not what you expected:

```raku-static
-> ;; $_? is raw { #`(Block|140570649867712) ... }
```

It parses the content between the curly braces as a pointy block.

What if you try double quotes?

```raku-static
EVAL("say {789}");
```

Now it even refuses to compile:

```raku-static
===SORRY!=== Error while compiling eval.pl

EVAL is a very dangerous function!!! (use the MONKEY-SEE-NO-
EVAL pragma to override this error,
but only if you're VERY sure your data contains no injection
attacks)
at eval.raku:6
⏏;
------> EVAL("say {789}")
```

We can fix the code by adding a few magic words:

```raku
use MONKEY-SEE-NO-EVAL;

EVAL("say {789}");
```

This time, it prints `789`.

The code is executed, so you can make some calculations, for example:

```raku
use MONKEY-SEE-NO-EVAL;

EVAL("say {7 / 8 + 9}"); # 9.875
```

Finally, if you try passing a code block directly, you cannot achieve the goal again, even with a blind monkey:

```raku-static
use MONKEY-SEE-NO-EVAL;

EVAL {say 123};
```

The error happens at runtime:

```raku-static
Constraint type check failed in binding to parameter '$code';
expected anonymous constraint to be met but got
-> ;; $_? is raw { #`...
  in block <unit> at eval.raku line 10
```

This message looks cryptic, but at least we see once again that we got an anonymous pointy block passed to the function.

And before we wrap up, an attempt to use a lowercase function name:

```raku-static
eval('say 42');
```

There is no such function in Raku, and we get an error message that proposes how to change the code to make it correct:

```raku-static
===SORRY!=== Error while compiling eval2.raku
Undeclared routine:
  eval used at line 5. Did you mean 'EVAL', 'val'?
```

{% include nav.html %}
