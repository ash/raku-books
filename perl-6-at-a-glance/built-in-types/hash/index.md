---
title: Hash
---

{% include menu.html %}

Hashes provide a few methods with clear semantics, for instance:

```raku-static
my %hash = Language => 'Perl', Version => 6;
```

```raku-static
say %hash.elems;  # number of pairs in the hash
say %hash.keys;   # the list of the keys
say %hash.values; # the list of the values
```

Here’s the output:

```
2
(Version Language)
(6 Perl)
```

It is possible to iterate not only over the hash keys or values but also over whole pairs:

```raku-static
for %hash.pairs {
    say $_.key;
    say $_.value;
}
```

The `.kv` method returns a list containing the alternating keys and values of the hash:

```raku-static
say %hash.kv # (Version 6 Language Perl)
```

{% include nav.html %}
