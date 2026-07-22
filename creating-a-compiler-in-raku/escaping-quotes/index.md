---
title: Escaping quotes
---

{% include menu.html %}

It is quite obvious that the above-defined string cannot contain double quotes inside itself. Let us not allow using single quotes to delimit the string as Perl does, but only allow escaping the quote character inside a string:

```raku
say "Hello, \"World\"!";
```

Currently, the parser stops at the second seen quote and terminates with an error:

```
Hello, \
Error: parse failed
```

To allow an escaped quote, the `string` rule must consume all non-quote and non-backslash characters, and if it sees a backslash, then only the sequence of `\"` is considered valid:

```raku-static
token string {
    '"' ( [
          | <-["\\]>+
          | '\\"'
          ]* )
    '"'
}
```

We prefer a token over a rule from this moment to avoid skipping spaces after the opening quote.

In Raku, you can format the regexes freely enough to form some kind of ASCII graphics that helps better grasping of a regex. As we did it earlier, an additional vertical bar is added again to visualise the alternatives.

An escaped quote character is now allowed, but the backslash itself became an illegal character in all other cases. Let’s add another escape sequence, `\\`, to present a single backslash in a string:

```raku-static
token string {
    '"' ( [
          | <-["\\]>+
          | '\\"'
          | '\\\\'
          ]* )
    '"'
}
```

All other sequences are not allowed, e.g., `"\W"` is an error. Below are a few examples of valid strings with slashes and quotes. A string may contain a newline or can be empty:

```raku
say "\\";
say "\"";
say "\\\\";
say "\"\"";
say "multi-
     line";
say "";
```

As we do not need an escaping backslash in the output, it should be removed from the string before passing it further:

```raku-static
method string($a) {
    my $s = ~$a[0];
    $s ~~ s:g/\\\"/"/;
    $s ~~ s:g/\\\\/\\/;
    $a.make($s);
}
```

(Notice that we had to change the name of the method argument as otherwise a runtime error occurs: `Cannot assign to a readonly variable ($/) or a value`.)

{% include nav.html %}
