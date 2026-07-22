---
title: 1. Hello, World!
---

{% include menu.html %}

*Print ‘Hello, World!’*

There are two built-in functions to print to the console: `print` and `say`. Both print their arguments, but the `say` routine additionally ends the output with a newline character.

So, the quickest solution is to use `say` and pass a string with no newlines:

```raku
say 'Hello, World!'
```

Another solution is to use `print` and include the `\n` character in the string itself:

```raku
print "Hello, World!\n"
```

The output of either program is the same:

```
Hello, World!
```

Notice the difference between single and double quotes: single quotes do not interpolate special characters like `\n` while the double quotes do. There’s no mistake in using double quotes for strings without special characters, while it is better to use the appropriate quoting style when you do not expect variables in the string and when there is no need to interpolate variables.

Another thing to take a look at in the examples above is that a semicolon is not required for one-line programs.

{% include nav.html %}
