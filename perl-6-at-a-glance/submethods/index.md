---
title: Submethods
---

{% include menu.html %}

Perl 6 defines the so-called submethods for classes. These are the methods which are not propagating to the subclass’s definition. The submethods may be either private or public, but they will not be inherited by the children.

```raku
class A {
    submethod submeth {
        say "A.submeth"
    }
}

class B is A {
}

my A $a;
my B $b;

$a.submeth;   # OK
# $b.submeth; # Error: No such method 'submeth' for invocant of type 'B'
```

{% include nav.html %}
