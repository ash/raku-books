---
title: 31. Divide by zero
---

{% include menu.html %}

*Do something with the division by zero.*

Division by zero in itself is not an immediate error in Raku.

The following code does not generate an exception and prints the message after the problematic division.

```raku
my $v = 42 / 0;
say 'It still works!';
```

However, as soon as the result stored in the `$v` variable is about to be displayed, the program stops execution with an error:

```raku-static
my $v = 42 / 0;
say $v;
```

The error message appears in the console:

```
Attempt to divide 42 by zero using div
  in block <unit> at divide0.rk line 2
```

The above-mentioned behaviour is called soft failure. It fails only if someone sees it :-) To catch the error, use the `try` and the `CATCH` blocks:

```raku
try {
    say 42 / 0;
    CATCH {
        default {
            say 'Error!';
        }
    }
}
say 'It still works!';
```

{% include nav.html %}
