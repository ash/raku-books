---
title: Hello, World!
---

{% include menu.html %}

In this chapter, we will create the main reference program printing
"Hello, World!".

In Perl, you can do it using either the `print` or the `say` built-in
function. In the pre-Perl 5.10 times, you would do it like this:

```perl
print "Hello, World!\n";
```

Since Perl 5.10, the same result can be achieved with more concise code (if you
do not count the `use` instruction):

```perl
use v5.10;
say 'Hello, World!';
```

You may be surprised, but the `say` function was actually back-ported to Perl
from Raku. For a historical reference, let me remind you that the first version
of `say` implemented in one of the very early Raku compilers was called
`print1`.

OK, now let us move on to modern times, and here is the same program in Raku:

```raku
say 'Hello, World!';
```

## Files

To run the program, save it in a file and pass it to the interpreter. There is
no difference between running Perl and Raku programs yet, but to distinguish
between the versions, we will be using the `.pl` file-name extension for the
Perl versions of programs and `.raku` for the Raku code. In principle, the
specification does not force you to use this extension, and you may continue
using `.pl` as before.

Running a Perl program from the command line:

```
$ perl 002-hello-world.pl
```

Running a Raku program:

```
$ raku 002-hello-world.raku
```

Now let us look at a few details that can still be found in the short programs
above.

First, in both languages, the semicolon separates different statements and can be
omitted if there is only one line in the whole program. So, the program in
Perl can gain one character:

```perl
print "Hello, World!\n"
```

As can the program in Raku:

```raku
say 'Hello, World!'
```

If you want to use `say` in Perl, you need to tell the compiler to activate the
features of versions 5.10+:

```
$ perl -mfeature=say 002-hello-world.raku
```

(Did you notice that we ran the Perl compiler and passed a Raku program to it?)

Of course, for one-liners, there is no need to save programs in files. Both
compilers support a command-line option to pass the code on the command line.
With Perl, it is either a traditional `-e` or a more recent `-E`. You use `-E`
to activate the 5.10+ features:

```
$ perl -e'print "Hello, World!\n"'
$ perl -E'say "Hello, World!"'
```

In Raku, `say` is activated by default, so we return to the lower-case option:

```
$ raku -e'say "Hello, World!"'
```

The `-E` option does not exist and is not supported in Raku.

## Quotes

The second thing you may want to dig into right now is the difference between
single and double quotes. Actually, there is no difference between how Perl and
Raku treat them in the examples above. :-)

Double quotes allow string interpolation (which we will cover soon) and allow
escaped characters such as the newline character `\n`. In the examples above, we
needed double quotes in the Perl program to add a new line at the end of the
output after using the `print` function. In the one-liners with `say`, double
quotes were only needed to prevent mixing them up with the outer single quotes on
the command line.

## Introducing variables

The next step up from the "Hello, World!" program would be to modify it to greet
a person. Let's first keep their name in a variable, and later we'll ask the user
to enter it from the keyboard.

Variables in Perl traditionally use *sigils* — a one-character non-alphabetic
prefix to indicate the structural type of the variable. Both in Perl and Raku
there are scalars, arrays, and hashes, and they share the same characters —
respectively, `$`, `@`, and `%`. But there are some important differences, and
we'll cover them shortly.

Two techniques can be illustrated with this greeting program. First, to keep a
person's name, a scalar is a good choice. Second, to print it, we can choose
string interpolation or string concatenation (or simply print the text pieces one
after another).

In Perl, the program may look like the following:

```perl
use v5.10;

my $name = 'John';
say "Hello, $name!";
```

There's absolutely no difference in the main code when you upgrade the program to
run under Raku:

```raku
my $name = 'John';
say "Hello, $name!";
```

From now on, let us assume that you add `use v5.10` in all Perl programs that
use `say`.

## Concatenating strings

Another, and probably less Perlish, way to build strings is string concatenation.
In Perl, the string concatenation operator is a dot:

```perl
my $name = 'John';
say 'Hello, ' . $name . '!';
```

In Raku, the dot is reserved for method calls. The string concatenation operator
is a tilde:

```raku
my $name = 'John';
say 'Hello, ' ~ $name ~ '!';
```

## Object-oriented elements

We will devote a whole chapter to object-oriented programs, but it is useful to
know from the very start that in Raku you can treat many things as objects. For
example, constants, strings, and variables — all of these are objects, and you
may call a method on them. Method-call syntax needs a dot, and that is why string
concatenation no longer uses it.

The basic "Hello, World!" program in Raku can be written in the following manner:

```raku
'Hello, World!'.say;
```

You call the `say` method on a string, and it does the same as the built-in
function of the same name.

There are more methods defined on strings; for example, this is how you convert
the string to uppercase and print it:

```raku
'Hello, World!'.uc.say;
```

## Reading the user's input

What if you want the user to enter their name rather than hardcoding it in the
program? Technically speaking, we mean that the name comes from `STDIN`.

In Perl, you can use the diamond operator to read a line from standard input:

```perl
print 'What is your name? ';
my $name = <>;
chomp $name;
say "Hello, $name!";
```

First, you print a prompt with a question, then Perl waits until the user types
the name and hits the Enter key. The newline character is also put into the
`$name` variable, so it is important to clean it out by calling `chomp`. Notice
that the built-in `chomp` function modifies its argument.

In Raku, the same program can be a bit more compact, as the language offers the
`prompt` built-in function, which you can use both to print the message and to
get the input:

```raku
my $name = prompt('What is your name? ');
say "Hello, $name!";
```

## More interpolation options

Are there any other options for rewriting the programs above? Of course — as
always in Perl, there is more than one way to do it. Both Perl and Raku
demonstrate their flexibility here.

A couple of tricks have been discovered to embed a piece of code into strings in
Perl. One of them is to use the following construct: `@{[...]}`. Here is how you
can use it (you can, but probably you should not):

```perl
print 'What is your name? ';
say "Hello, @{[$name = <> and chomp $name and $name]}!";
```

For the end user, the program works as before: it asks for the name and prints
the greeting. For the programmer, it is a mess of characters and compromises
(such as using the Boolean `and` to make it one big expression rather than using
a comma to separate statements).

In Raku, code interpolation is a built-in feature and can be used directly with
no tricky techniques involved:

```raku
say "Hello, {prompt('What is your name? ')}!";
```

For better readability, apply some formatting:

```raku
say "Hello, {
    prompt('What is your name? ')
}!";
```

## Parentheses in function calls

Did you notice that we called functions such as `say`, `print`, and `prompt`,
passed arguments to them, but never used parentheses? In both languages, simple
uses such as those shown earlier are fine both with and without parentheses.
Still, for clarity — and if your coding standards demand it — surround the
arguments with parentheses.

An updated Perl "Hello, World!" program:

```perl
say('Hello, World!');
```

An updated Raku equivalent looks the same:

```raku
say('Hello, World!');
```

So far so good, but what if you pass more than one string to the `say` routine?
It is possible in both Perl and Raku:

```perl
say('Hello, ', 'World!');
```

```raku
say('Hello, ', 'World!');
```

Why bother you with these examples? There is a big difference if you add a space
between the function name and the opening parenthesis:

```perl
say ('Hello, ', 'World!');
```

```raku
say ('Hello, ', 'World!');
```

Perl sees here the same function call with two parameters and prints the output
as expected:

```
Hello, World!
```

Raku treats this code differently. It passes a *single* argument to the `say`
function, and that argument is a list containing two strings. That's why you will
see the list in the output, not a plain string:

```
(Hello, World!)
```

It may be a good idea to always use parentheses — and always keep in mind that
the space is semantically meaningful in Raku.

## Identifiers

Identifiers — which include, in the first place, the names of variables,
functions, and modules — are traditionally built using the letters of the
English (or Latin, if you prefer) alphabet, digits, and the underscore character.

In Raku, however, you are not limited to the ASCII subset, and can use many
characters that are recognised as letters in Unicode. For example, here's a
"Greek version" of the "Hello, World!" program in Raku:

```raku
my $όνομα = 'John';
say $όνομα;
```

This is also possible in Perl, but you need to activate the feature by adding
the `utf8` pragma:

```perl
use utf8;

my $όνομα = 'John';
say $όνομα;
```

In Raku, you can go a bit further and use dashes and apostrophes in variable
names. For example:

```raku
my $first-name = 'John';
say $first-name;
```

Or:

```raku
my $don't = 'Do not!';
say $don't;
```

In my opinion, dashes are fine, but it is better not to use apostrophes — though
they are still perfectly valid.

{% include nav.html %}
