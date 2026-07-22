---
title: 82. Simple string compressor
---

{% include menu.html %}

*Convert a string containing repeating characters to a string, where each repetition is represented by the character and the number of its copies.*

For example, the original string `abccccdefffffggghhi` converts to the compressed string `abc4def5g3h2i`.

```raku-nobrowser
my $str = 'abccccdefffffggghhi';

$str ~~ s:g/
        ( (<:alpha>) $0+ )
    /{
        $0[0] ~ $0.chars
    }/;

say $str; # abc4def5g3h2i
```

The global replacement finds the parts of the string with repeated characters. The tricky part in the regex is the way in which capturing parentheses are counted.

The naïve regex `<:alpha>+` matches any letter sequence and consumes the whole string. Thus, only one character must be captured: `(<:alpha>)`. Now, the regex should demand repetitions of that character: `$0+`, but we also need to capture it as we have to know the length of it.

It is not possible to say `(<:alpha>)($0+)`, as `$0` is referring to the capturing part in the second parentheses. The final regex contains nested capturing parentheses.

The `$0` match object keeps the whole repeated sequence and the array with one element that holds the first matched character. The replacement part uses both elements to build the result: `$0[0] ~ $0.chars`.

{% include nav.html %}
