---
title: Executable
---

{% include menu.html %}

The first thing to do in this chapter is to make the translator (which latter will become a compiler) a proper executable program so that we can easily call it from the command line and pass the filename containing a Lingua program to it:

```raku-static
./lingua my-prog.lng
```

The `lingua` executable has to check whether you passed the filename and if the file exists, and after that it parses and executes the input program. Here is the whole code:

```raku-static
#!/usr/bin/env raku

use lib 'lib';
use Lingua;
use LinguaActions;

error('Usage: ./lingua <filename>') unless @*ARGS.elems;

my $filename = @*ARGS[0];
error("Error: File $filename not found") unless $filename.IO.f;

my $code = $filename.IO.slurp();
my $result = Lingua.parse($code, :actions(LinguaActions));
say $result ?? 'OK' !! error('Error: parse failed');

sub error($message) {
    note $message;
    exit;
}
```

The `error` function prints an error message and terminates the program. It uses the `note` built-in function, which behaves like `say` but sends the output to the standard error stream. The `die` routine is not used here as it prints additional information about the location of the error, which is not really needed in this case. Suppressing the extra output of `die` needs roughly the same number of lines as introducing a new function.

{% include nav.html %}
