---
title: :
---

{% include menu.html %}

`:` marks the left side of it as an invocant to call a method on, when a method of an object is used. It is easier to understand how it works in the following example.

```raku
class C {
    method meth($x) {
        say "meth($x)";
    }
}
my $o = C.new;
meth($o: 42); # The meth method of the $o object is called,
              # it prints “meth(42)”
```

The form `meth($o: 42)` is equivalent to the classical form `$o.meth(42)`. Note that you cannot omit a space following the colon (otherwise, it will be interpreted as a named argument).

Another common Perl 6 idiom for the use of `:` is to prevent having parentheses with method calls. The following two lines of code are equivalent:

`say "abcd".substr: 1, 2; # bc`

`say "abcd".substr(1, 2); # bc`

{% include nav.html %}
