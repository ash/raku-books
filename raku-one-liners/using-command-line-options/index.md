---
title: Using command-line options
---

{% include menu.html %}

Let us talk about the command-line options that the Rakudo1 compiler offers to us.

-e

The first option to know when working with Raku is `-e`. It takes a string with your Perl 6 one-liner and executes it immediately.

For example, print the name of the current user:

```
$ perl6 -e'$*USER'

ash
```

-n

This option repeats the code for each line of input data. This is quite handy when you want to process a file. For example, here’s a one-liner that adds up the values in a row and prints the sum:

```
$ raku -ne'say [+] .split(" ")' data.txt
```

If the `data.txt` file contains the following:

```
10 20 30 40
1 2 3 4
5 6 7 8
```

1 Rakudo (rakudo.org) is an implementation of Raku. The rest of the book assumes you are using the Rakudo compiler and run it as `raku` from command line. If you have an older version, which has the `perl6` executable, make an alias in your `.pro-`

```
file: alias raku=perl6.
```

then the result of the one-liner is:

There’s no difference whether you use shell’s input redirection or not; the following line also works:

```
$ raku -ne'say [+] .split(" ")' < data.txt
```

Make sure you place the `e` option the last in the list (so, not `raku -en'...'`) or split the options: `raku -n -e'...'`.

-p

This option is similar to `-n` but prints the topic variable after each iteration.

The following one-liner reverses the lines in the file and prints them to the console:

```
$ raku -npe'.=flip' data.txt
```

For the same input file, the result will look like this:

```
04 03 02 01
4 3 2 1
8 7 6 5
```

Notice that you have to update the `$_` variable, so you type `.=flip`. If you only have `.flip`, you only reverses the string, but the result is not used and the original line is printed.

An equivalent program with `.flip` and with no `-p` looks like this:

```
$ raku -ne'.flip.say' data.txt
```

{% include nav.html %}
