---
title: Array and hash assignment and initialisation
---

{% include menu.html %}

We skipped initialising arrays and hashes and did it for a reason. Let us first make the AST for cases when you declare and assign in two different statements, as shown in the next example:

```raku-static
my d[];
d = 3, 5, "7";

my e{};
e = "1": 2, "3": "4";
```

Array and hash assignment is different from assigning individual elements, so these actions require their own types of AST nodes:

```raku-static
class AST::ArrayAssignment is ASTNode {
    has Str $.variable-name;
    has ASTNode @.elements;
}

class AST::HashAssignment is ASTNode {
    has Str $.variable-name;
    has Str @.keys;
    has ASTNode @.values;
}
```

For arrays, we collect the elements in the array consisting of some AST nodes. For hashes, the keys and the values are kept in separate arrays, and keys are forced to be strings. Alternatively, we could create `Pair` (that’s on of the Raku’s built-in types) objects to combine the key—value pairs.

In the actions, we have to carefully separate assignments to scalars, arrays and hashes. Multi-methods work quite well here, while it may require a lot of conditions in the `where` clause. Another approach would be to split the `assignment` rule into three, one per the data type. Anyway, here’s our current implementation of the action methods:

```raku-static
multi method assignment($/ 
    where !$<index> && !$<value>) {
    $/.make(AST::ScalarAssignment.new(
        variable-name => ~$<variable-name>,
        rhs => $<value>[0].made
    ));
}

multi method assignment($/ 
    where !$<index> && $<value> && !$<string>) {
    $/.make(AST::ArrayAssignment.new(
        variable-name => ~$<variable-name>,
        elements => $<value>.map: *.made
    ));
}

multi method assignment($/ 
    where !$<index> && $<value> && $<string>) {
    $/.make(AST::HashAssignment.new(
        variable-name => ~$<variable-name>,
        keys => ($<string>.map: *.made.value),
        values => ($<value>.map: *.made)
    ));
}
```

Examine this code carefully: you should understand how method signatures help to select the right method for each given situation. In this code, a lot of `map` methods are used too, they are always concise and mostly clear but not always easy to write.

The next step is to complete the assignment with initialisation actions, and we already have the code for them. Extract it to separate functions (as we did earlier in the interpreter), and here is the final result.

Array-related methods:

```raku-static
sub init-array($variable-name, $elements) {
    return AST::ArrayAssignment.new(
        variable-name => $variable-name,
        elements => $elements.map: *.made
    );
}

multi method array-declaration($/ where $<value>) {
    $/.make(init-array(~$<variable-name>, $<value>));
}

multi method assignment($/ where !$<index> && $<value> && !$<string>) {
    $/.make(init-array(~$<variable-name>, $<value>));
}
```

The code looks transparent and self-explanatory again. Repeat the same for the hash-related code:

```raku-static
sub init-hash($variable-name, $keys, $values) {
    return AST::HashAssignment.new(
        variable-name => $variable-name,
        keys => ($keys.map: *.made.value),
        values => ($values.map: *.made)
    );
}

multi method hash-declaration($/
    where $<string> && $<value>) {
    $/.make(init-hash(~$<variable-name>, 
                  $<string>, $<value>));
}

multi method assignment($/
    where !$<index> && $<value> && $<string>) {
    $/.make(init-hash(~$<variable-name>, 
                      $<string>, $<value>));
}
```

Many of the grammar rules are now covered. Let us continue with filling the gaps in the new architecture of the compiler and implement the AST elements for expressions and function calls. Our goal is to either have action methods that just pass the `made` value to the next level or which put one of the `AST::*` objects in the `made` attribute.

{% include nav.html %}
