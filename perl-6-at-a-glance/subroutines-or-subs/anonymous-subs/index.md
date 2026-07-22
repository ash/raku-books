---
title: Anonymous subs
---

{% include menu.html %}

Let’s look at the creation of anonymous subs. One of the options (there are more than one) is to use syntax similar to what you often see in JavaScript.

```raku
say sub ($x, $y) {$x ~ ' ' ~ $y}("Perl", 6);
```

The first pair of parentheses contains the list of formal arguments of the anonymous sub; the second, the list of the arguments passed. The body of the sub is located between the braces. (The tilde denotes a string concatenation operator in Perl 6.)

By the way, it is important that there be no spaces before parentheses with the actual values of the sub parameters.

Another way of creating an anonymous sub is to use the arrow operator (`->)`. We will discuss it later in the section dedicated to anonymous blocks.

{% include nav.html %}
