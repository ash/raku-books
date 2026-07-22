---
title: Off-topic: The joy of syntax
---

{% include menu.html %}

Before going on with more features for arrays and hashes, let us transform the grammar a bit. In the `assignment` method, the `if`-`else` check occupies more lines than the “useful” code. We can do two things to make the methods more compact.

First, let us repeat the trick with splitting a rule into two. Instead of one universal `assignment` rule, we can have two subrules:

```raku-static
rule assignment {
    | <array-item-assignment>
    | <scalar-assignment>
}

rule array-item-assignment {
    <variable-name> [ '[' <integer> ']' ] '=' <value>
}

rule scalar-assignment {
    <variable-name> '=' <value>
}
```

It made the grammar more verbose, but the action became more compact:

```raku-static
method array-item-assignment($/) {
    %!var{~$<variable-name>}[+$<integer>] = $<value>.made;
}

method scalar-assignment($/) {
    %!var{~$<variable-name>} = $<value>.made;
}
```

The second possible solution is to keep the original `assignment` rule and use the `where` clause in method’s signatures and dispatch the calls depending of the content of the match object.

```raku-static
multi method assignment($/ where $<integer>) {
    %!var{~$<variable-name>}[+$<integer>] = $<value>.made;
}

multi method assignment($/ where !$<integer>) {
    %!var{~$<variable-name>} = $<value>.made;
}
```

The negative condition in the signature of the second variant of the multi-method is optional, but I’d advise to keep it for clarity of the code.

There are two more actions that can be re-written in the same manner. The `value` action:

```raku-static
multi method value($/ where $<expression>) {
    $/.make($<expression>.made);
}

multi method value($/ where $<string>) {
    $/.make($<string>.made);
}
```

The second action with a big `if`-`elsif`-`else` condition is `expr`:

```raku-static
multi method expr($/ where $<number>) {
    $/.make($<number>.made);
}

multi method expr($/ where $<string>) {
    $/.make($<string>.made);
}

multi method expr($/ where $<variable-name> && $<integer>) {
    $/.make(%!var{$<variable-name>}.substr(+$<integer>, 1));
}

multi method expr($/ where $<variable-name> && !$<integer>) {
    $/.make(%!var{$<variable-name>});
}

multi method expr($/ where $<expr>) {
    $/.make(process($<expr>, $<op>));
}

multi method expr($/ where $<expression>) {
    $/.make($<expression>.made);
}
```

These methods look trivial now. Notice that some of the candidates check more than one key in the match object.

{% include nav.html %}
