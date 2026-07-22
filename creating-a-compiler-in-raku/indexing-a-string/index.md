---
title: Indexing a string
---

{% include menu.html %}

Getting a given character from a string is a good addition to the strings in our language. Let us allow the standard syntax like this:

```raku-static
my s = "abcdef";
say s[3]; # prints d
```

We only allow indexing if the string is stored in a variable, thus let’s update the corresponding rule to have an optional integer index in square brackets:

```raku-static
multi rule expr(4) {
    | <number>
    | <variable-name> [ '[' <integer> ']' ]?
    | '(' <expression> ')'
}
```

In the action, check if the integer attribute is present, and return a requested character:

```raku-static
method expr($/) {
    . . .
    
    elsif $<string> {
        $/.make($<string>.made);
    }
    elsif $<variable-name> {
        if $<integer> {
            $/.make(
                %!var{$<variable-name>}.substr(
                +$<integer>, 1));                                            
        }
        else {
            $/.make(%!var{$<variable-name>});
        }
    }

    . . .
}
```

Indexing does not work with string interpolation, but you can always use a temporary variable to achieve the goal:

```raku-static
my ch = s[4];
say "The 4th character is \"$ch\""; # e
```

As an exercise, try implementing string indices in interpolated strings. Be ready to think of escaping square brackets outside of the index.

{% include nav.html %}
