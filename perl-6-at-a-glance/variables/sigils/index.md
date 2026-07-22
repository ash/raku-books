---
title: Sigils
---

{% include menu.html %}

Perl 6 uses sigils to mark variables. The sigils are partially compatible with the Perl 5 syntax. For instance, scalars, lists and hashes use, respectively, the `$`, `@`, and `%` sigils.

```raku
my $scalar = 42;
say $scalar;
```

It’s not a surprise that the code prints `42`.

Consider the following fragment, which also gives a predictable result (the square brackets indicate an array):

```raku
my @array = (10, 20, 30);
say @array; # [10 20 30]
```

Now, let's use the advantages of Perl 6 and rewrite the above code, using less typing, both fewer characters and less punctuation:

```raku-static
my @list1 = <10 20 30>;
```

Or even like this:

```raku-static
my @list2 = 10, 20, 30;
```

Similarly, we can omit parenthesis when initializing a hash, leaving the bare content:

```raku
my %hash =
    'Language' => 'Perl',
    'Version'  => '6';
say %hash;
```

This small programme prints this (the order of the hash keys in the output may be different, and you should not rely on it):

```
{Language => Perl, Version => 6}
```

To access the elements of a list or a hash, Perl 6 uses brackets of different types. It is important to remember that the sigil always remains the same. In the following examples, we extract a scalar out of a list and a hash:

```raku
my @squares = 0, 1, 4, 9, 16, 25;
say @squares[3]; # This prints the 4th element, thus 9
```

```raku
my %capitals =
    'France'  => 'Paris',
    'Germany' => 'Berlin';

say %capitals{'Germany'};
```

An alternative syntax exists for both creating a hash and for accessing its elements. To understand how it works, examine the next piece of code:

```raku
my %month-abbrs =
    :jan('January'),
    :feb('February'),
    :mar('March');
say %month-abbrs<mar>; # prints March
```

Naming a variable is a rather interesting thing as Perl 6 allows not only ASCII letters, numbers, and the underscore character but also lots of the UTF-8 elements, including the hyphen and apostrophe:

```raku
my $hello-world = "Hello, World";
say $hello-world;

my $don't = "Isn’t it a Hello?";
say $don't;

my $привет = "A Cyrillic Hi!";
say $привет;
```

Would you prefer non-Latin characters in the names of the variables? Although it may slow down the speed of your typing, because it will require switching the keyboard layout, using non-Latin characters in names of variables does not have any performance impact. But if you do, always think of those developers, who may need to read your code in the future.

{% include nav.html %}
