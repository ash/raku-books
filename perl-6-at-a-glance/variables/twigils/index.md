---
title: Twigils
---

{% include menu.html %}

In Perl 6, a variable name may be preceded by either a single-character sigil, such as `$`, `@` or `%`, or with a double character sequence. In the latter case, this is called a twigil. The first character of it means the same thing that a bare sigil does, while the second one extends the description.

For example, the second character of the twigil can describe the scope of the variable. Consider `*`, which symbolises dynamic scope (more on this in Chapter 3). The following call prints the command line arguments one by one:

```raku-local
.say for @*ARGS;
```

Here, the `@*ARGS` array is a global array containing the arguments received from the command line (note that this is called `ARGS` and not `ARGV` as in Perl 5). The `.say` construction is a call of the `say` method on a loop variable. If you want to make it more verbose, you would write it like this:

```raku-local
for @*ARGS {
    $_.say;
}
```

Let’s list a few other useful predefined dynamic variables with the star in their twigils. The first element of the twigil denotes the type of a container (thus a scalar, an array, or a hash):

`$*PERL` contains the Perl version (Perl 6)

`$*PID` — process identifier

`$*PROGRAM-NAME` — the name of the file with the currently executing programme (for a one-liner its value is set to -e)

`$*EXECUTABLE` — the path to the interpreter

`$*VM` — the name of the virtual machine, which your Perl 6 has been compiled with

`$*DISTRO` — the name and the version of the operation system distribution

`$*KERNEL` — similar, but for the kernel

`$*CWD` — the current working directory

`$*TZ` — the current timezone

`%*ENV` — the environment variables

In my case, the variables above took the following values:

```
Perl 6 (6.c)
90177
twigil-vars.pl
"/usr/bin/perl6".IO
moar (2016.11)
macosx (10.10.5)
darwin (14.5.0)
"/Users/ash/Books/Perl 6/code".IO
{Apple_PubSub_Socket_Render => /private/tmp/com.apple…., DISPLAY => /private/tmp/com.apple…, HISTCONTROL => ignorespace, HOME => /Users/ash, LC_CTYPE => UTF-8, LOGNAME => ash ...
```

The next group of the predefined variables include those with the `?` character as their twigil. These are “constants” or so-called compile-time constants, which contain information about the current position of the programme flow.

`$?FILE` — the name of the file with a programme (no path included; contains the string `-e` for one-liners)

`$?LINE` — the line number (is set to 1 for one-liners)

`$?PACKAGE` — the name of the current module; on a top level, this is `(GLOBAL)`

`$?TABSTOP` — the number of spaces in tabs (might be used in heredocs)

{% include nav.html %}
