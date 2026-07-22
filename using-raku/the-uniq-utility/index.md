---
title: 96. The uniq utility
---

{% include menu.html %}

*Create the simple equivalent of the UNIX uniq utility, which only prints the lines from the STDIN input, which are not repeating the previous line.*

The solution of this task can be built on the solution of Task 95, The cat utility. This time, the entered lines have to be saved, so let’s introduce the `$previous` variable and make an explicit code block for the loop.

```raku-static
my $previous = '';
while (my $line = $*IN.get) {
    say $line unless $line eq $previous;
    $previous = $line;
}
```

On each iteration, the next line from the `$*IN` handle is read and saved in the `$line` variable. If the value is different from the previous line, which is saved in the `$previous` variable, then the current line has been printed.

At the moment, only duplicated lines are affected. If the two identical lines are separated by other lines, then everything is printed. Let us modify the program so that it only prints the unique lines per whole input stream.

```raku-static
my %seen;
while (my $line = $*IN.get) {
    next if %seen{$line};
    say $line;
    %seen{$line} = 1;
}
```

Here, the `%seen` hash is used as a storage of the lines printed. It’s also a good practice to use a `Set` object instead; see the example of using a set in Task

*54, Exclusion of two arrays.*

{% include nav.html %}
