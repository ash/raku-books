---
title: Reviewing the calculator
---

{% include menu.html %}

The part of the grammar that came from the calculator includes a few parts which resemble each other.

```raku-static
rule expression {        
    <term>* %% <op1>
}

rule term {
    <factor>* %% <op2>
}

rule factor {
    <value>* %% <op3>
}
```

But first, let us think of the quantifiers in there. The star allows any number of repetitions of either `term`, or `factor`, or `value`. What if it really happens in the program with no expression, say, as shown below:

```raku-static
my x;
x = ;
say x;
```

This is obviously wrong, but the `Lingua` grammar does not return `Nil`. It fails earlier, producing an undesired output from Raku:

```raku-static
Cannot shift from an empty Array
  in sub process at /Users/ash/lingua/LinguaActions.pm (LinguaActions) line 52
  in method factor at /Users/ash/lingua/LinguaActions.pm (LinguaActions) line 46
  in regex factor at /Users/ash/lingua/Lingua.pm (Lingua) line 48
  in regex term at /Users/ash/lingua/Lingua.pm (Lingua) line 44
  in regex expression at /Users/ash/lingua/Lingua.pm (Lingua) line 40
  in regex assignment at /Users/ash/lingua/Lingua.pm (Lingua) line 23
  in regex statement at /Users/ash/lingua/Lingua.pm (Lingua) line 13
  in regex TOP at /Users/ash/lingua/Lingua.pm (Lingua) line 6
  in block <unit> at ./lingua line 13

Actually thrown at:
  in method function-call at /Users/ash/lingua/LinguaActions.pm (LinguaActions) line 13
  in regex function-call at /Users/ash/lingua/Lingua.pm (Lingua) line 27
  in regex statement at /Users/ash/lingua/Lingua.pm (Lingua) line 13
  in regex TOP at /Users/ash/lingua/Lingua.pm (Lingua) line 6
  in block <unit> at ./lingua line 13
```

That’s not what a user wants to see. The compiler broke instead of generating an error message. We have to change the grammar and demand at least one value at the place where an expression is expected. The simplest modification is to replace `*` with `+`:

```raku-static
rule expression {
    <term>+ %% <op1>
}

rule term {
    <factor>+ %% <op2>
}

rule factor {
    <value>+ %% <op3>
}
```

Now, we control the error message ourselves:

```
Error: parse failed
```

{% include nav.html %}
