---
title: Classes
---

{% include menu.html %}

We have already seen elements of the object-oriented programming in Perl 6. Methods may be called on those variables, which do not look like real objects from the first view. Even more, methods may be called on constants.

The types that were used earlier (like `Int` or `Str`) are container types. Variables of a container type can contain values corresponding to some native representation. The compiler does all the conversion it needs for executing a programme. For example, when it sees `42.say`, it calls the `say` method, which the `Int` object inherits from the top of the type hierarchy in Perl 6.

Perl 6 also supports object-oriented programming in its general understanding. If you are familiar with how to use classes in other modern programming languages, it will be easy for you to work with classes in Perl 6.

This is how the class is declared:

```raku-static
class Cafe {
}
```

{% include nav.html %}
