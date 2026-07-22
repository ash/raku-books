---
title: Get rid of globals
---

{% include menu.html %}

For storing variable values, we are using a global hash `%var`. Let’s make it more elegant and move it to the actions class as a data member.

```raku-static
class LinguaActions {
    has %!var;

    . . .
}
```

Of course, you should replace all occurrences of `%var` to `%!var` now, for example, in the assignment action (there are three more such places in the LinguaActions class):

```raku-static
method assignment($/) {
    %!var{~$<variable-name>} = $<expression>.made;
}
```

And finally, as we need a place for the hash, you need to instantiate the actions class before calling the parse method:

```raku-static
my $result = Lingua.parse($code,
                          :actions(LinguaActions.new));
```

{% include nav.html %}
