---
title: Hashes
---

{% include menu.html %}

In the remaining part of this chapter, we will implement hashes in our Lingua language. You have seen most of the ideas on the example of arrays, so the changes will be transparent and obvious. So, we have to implement a few things: declaration, declaration with initialisation, assignment to the whole hash and to a single element, reading the value and printing the hash.

The following fragments demonstrate the syntax we use. To declare a hash, use a pair of curly braces after the name of the variable:

```raku-static
my data{};
```

Initialisation and assignments are done using the comma-separated list of key—value pairs. Keys are always strings, values can be any scalar value (numbers or strings). The separator between the key and the value is a colon:

```raku-static
my hash{} = "alpha" : 1, "beta": 2, "gamma": 3;

my days{};
days = "Mon": "work", "Sat": "rest";
```

The grammar includes a separate rule for hash declaration:

```raku-static
rule variable-declaration {
    'my' [
        | <array-declaration>
        | <hash-declaration>
        | <scalar-declaration>
    ]
}

rule hash-declaration {
    <variable-name> '{' '}' [
        '=' [ <string> ':' <value> ]+ %% ','
    ]?
}
```

The assignment rule should know how to deal with hashes. This time, the changes can be done in-place without creating new rules.

```raku-static
rule assignment {
    <variable-name> <index>? '='
        [
            | [ <string> ':' <value> ]+ %% ','
            |                <value>+   %% ','
        ]
}
```

In the actions, you have to carefully implement the declaration and hash assignment methods. They both use a common code to set the keys and the values of the hash, which is placed in the `init-hash` method.

```raku-static
method init-hash($variable-name, @keys, @values) {
    %!var{$variable-name} = Hash.new;
    while @keys {
        %!var{$variable-name}.{@keys.shift.made} =
            @values.shift.made;
   }
}

multi method hash-declaration($/) {
    self.init-hash($<variable-name>, $<string>, $<value>);
}

multi method assignment($/ where !$<index>) {
    . . .
    elsif %!var{$<variable-name>} ~~ Hash {
        self.init-hash($<variable-name>, 
                       $<string>, $<value>);
    }
    . . .
}
```

Another part of hash implementation is to allow value access using keys. It is wise to re-use the `index` rule and make it a collection of two alternatives:

```raku-static
rule index {
    | <array-index>
    | <hash-index>
}

rule array-index {
    '[' <integer> ']'
}

rule hash-index {
    '{' <string> '}'
}
```

Use the new rules in the already existing methods. The where clauses receive an additional condition to make sure we caught the rule we want.

```raku-static
multi method assignment($/ where $<index> && 
                        $<index><array-index>) {
    %!var{$<variable-name>}[$<index>.made] =
        $<value>[0].made;
}

multi method assignment($/ where $<index> &&
                        $<index><hash-index>) {
    %!var{$<variable-name>}{$<index>.made} =
        $<value>[0].made;
}

multi method assignment($/ where !$<index>) {
    . . .
    elsif %!var{$<variable-name>} ~~ Hash {
        self.init-hash($<variable-name>,
                       $<string>, $<value>);
    }
    . . .
}
```

The new index `rule` will already work in the `expr(4)` rule, which allows us to read the values by the given hash key using the `hash{"key"}` syntax. All we need is to update the `expr` method to let it know about the new data structure:

```raku-static
multi method expr($/ where $<variable-name> && $<index>) {
    . . .
    elsif %!var{$<variable-name>} ~~ Hash {
        $/.make(%!var{$<variable-name>}{$<index>.made});
    }
    . . .
}
```

Add the following lines to a test program and confirm that it works:

```raku-static
days{"Tue"} = "work";
say days{"Sat"};
```

Finally, teach the `say` function to print hashes:

```raku-static
method function-call($/) {
    . . .
    elsif $object ~~ Hash {
        my @str;
        for $object.keys.sort -> $key {
            @str.push("$key: $object{$key}");
        }
        say @str.join(', ');
    }
    . . .
}
```

If you are good at using the `map` method, try making a better version of the function. The expected output in response to `say days;` should be like this:

```
Mon: work, Sat: rest, Tue: work
```

{% include nav.html %}
