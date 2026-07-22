---
title: 83. %Templating% engine
---

{% include menu.html %}

*Implement a simple templating engine, which substitutes values in placeholders of the form %name%.*

The objective is to create a function that takes a template string and a hash with named values and does the substitution. So, let us prepare and pass them to a function. Notice that, in Raku, it is possible to pass a hash as easy as you pass a scalar (see also Task 65, Passing arrays to subroutines).

```raku-static
my $template = 'Hello, %name%! Welcome to %city%!';
my %data = (
    name => 'Klara',
    city => 'Karlovy Vary',
);

say process_template($template, %data);
```

Inside the function, the hash is passed as a single hash variable.

```raku-static
sub process_template($template is copy, %data) {
    $template ~~ s:g/ '%' (\w+) '%' /%data{$0}/;
    return $template;
}
```

The function modifies the value of the first argument; this is why it is marked with the `is copy` trait.

The regex is global, which is turned on by the `:g` regex adverb. A regex is looking for words between the two percentage symbols. In Raku, non-alphanumeric characters must be quoted or escaped, so both `'%'` and `\%` are accepted. The second part of the replacement is using the matched value as the key for fetching the value from the `%data` hash.

{% include nav.html %}
