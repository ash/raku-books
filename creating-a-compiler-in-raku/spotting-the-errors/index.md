---
title: Spotting the errors
---

{% include menu.html %}

The above tests all passed but let us try for example a simple string indexing:

```raku-static
my abc = "abcdef";
say abc[0]; ## a
say abc[3]; ## d
say abc[5]; ## f
```

This time the test fails with the following report:

```
t/string-index.t... 
GOT: abcdef

EXPECTED: a
d
f

FAIL
```

Instead of printing a single character, we have the whole string printed (and only once). In the error message that follows the output you will see some explanation that comes from Raku:

```
# Index out of range. Is: 3, should be in 0..0
```

We screwed the index and either did not save it properly in the AST node or did not use it later. Here is the fragment of the tree corresponding to the first two printing instructions:

```raku-static
AST::FunctionCall.new(
    function-name => "say", 
    value => AST::ArrayItem.new(
        variable-name => "abc", 
        index => AST::NumberValue.new(
            value => 0
        )
    )
), 
AST::FunctionCall.new(
    function-name => "say", 
    value => AST::ArrayItem.new(
        variable-name => "abc", 
        index => AST::NumberValue.new(
            value => 3
        )
    )
),
```

The first assumption is not confirmed, as we see that the index is stored in the corresponding attribute of the AST node. Let us switch to the evaluator and see how the value is used there. Our candidate is a multi-method taking an array item:

```raku-static
multi method call-function('say', AST::ArrayItem $item) {        
    say %!var{$item.variable-name}[$item.index.value];
}
```

The parser understood the code as an array index, and the call-function method treats a string as an array. That works when the index is 0, because in Raku you can always “index” a scalar value:

```
$ raku
To exit type 'exit' or '^D'
> my $x = 10;
10
> say $x[0];
10
```

With a non-zero index, the above-seen error pops up:

```
> say $x[3];
Index out of range. Is: 3, should be in 0..0
  in block <unit> at <unknown file> line 1
```

Indeed, how from taking a look at the line `say abc[3]` you can tell if the variable `abc` is an array or a string. We got rid of any sigils to make the language cleaner but now it would be nice to get them back. With sigil, it is much easier to distinguish between `$abc` and `@abc`. You can get even further and use some kind of Hungarian notation to let the compiler know the type of the variable. Say, `$s_abc` can store strings only, and `$i_abc` only integers. Although it helps the compiler, it makes the language heavier for the end user.

Let us ask computer to check the type of the variable at runtime. We did that already for the other alternatives of the multi-function. Here is the updated version that only handles strings:

```raku-static
multi method call-function('say', AST::ArrayItem $item
    where %!var{$item.variable-name} ~~ Str) {             
    say %!var{$item.variable-name}.substr(
        $item.index.value, 1);
}
```

Run the test suite, and you’ll confirm that the test is passing. Unfortunately, another test becomes broken:

```
. . .
t/variable-declaration.t... OK
--------- Summary ---------
1 test file failed:
```

This example demonstrates how helpful are tests. Without them, you may change the thing without noticing that something else starts working incorrectly. Fortunately, we discovered it pretty quickly, and the solution is just to return the previously modified multi-method that covers the missing code:

```raku-static
multi method call-function('say', AST::ArrayItem $item
    where %!var{$item.variable-name} ~~ Array) {
    say %!var{$item.variable-name}[$item.index.value];
}
```

The test suite is now reporting all green:

```
$ ./run-tests 
t/array-creation.t... OK
t/expressions.t... OK
t/expressions2.t... OK
t/hash-creation.t... OK
t/numbers.t... OK
t/string-escaping.t... OK
t/string-index.t... OK
t/string-interpolation.t... OK
t/string.t... OK
t/variable-as-index.t... OK
t/variable-declaration.t... OK
--------- Summary ---------
All tests successfully ran.
```

{% include nav.html %}
