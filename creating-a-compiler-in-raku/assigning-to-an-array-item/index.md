---
title: Assigning to an array item
---

{% include menu.html %}

OK, now we can create an array and it’s time to fill its elements with some data:

```raku-static
data[0] = 10;
data[1] = 20;
```

The assignment rule can be updated similarly to how we did it with string indexing in the previous chapter with an optional integer index in square brackets:

```raku-static
rule assignment {
    <variable-name> [ '[' <integer> ']' ]? '=' <value>
}
```

In the corresponding action, the presence of the index indicates that we are working with an array, otherwise it is a scalar variable.

```raku-static
method assignment($/) {
    if $<integer> {
        %!var{~$<variable-name>}[+$<integer>] =
            $<value>.made;
    }
    else {
        %!var{~$<variable-name>} = $<value>.made;
    }
}
```

After you run the program with the above assignments, the data variable will keep two values in the storage:

```raku-static
Hash %!var = {:data($[10, 20])}
```

{% include nav.html %}
