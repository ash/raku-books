---
title: A proper command line
---

{% include menu.html %}

The main work is done, but before we look back at the road, Raku has one more gift for us. Throughout the book, we were running Lingua programs together with the dumps of the syntax tree and of the variable storage. The dumps go to STDERR, and they were extremely useful while we were developing the compiler, but a user of the language expects the interpreter to be silent and only print what the program prints.

Meet the `MAIN` function. If your program defines a function with this name, Raku calls it for you and parses the command-line arguments against its signature. Positional parameters become required arguments, named parameters become options, and the `Bool` type turns an option into a flag. Here is the final version of the `lingua` script:

```raku-static
#!/usr/bin/env raku

use lib 'lib';
use LinguaGrammar;
use LinguaActions;
use LinguaOptimizer;
use LinguaEvaluator;

sub MAIN(
    Str $filename,        #= a program in Lingua
    Bool :$ast,           #= dump the syntax tree
    Bool :$vars,          #= dump the variable storage
    Bool :$no-optimize,   #= skip the optimisation pass
) {
    error("Error: File $filename not found")
        unless $filename.IO.f;

    my $code = $filename.IO.slurp();

    my $evaluator = LinguaEvaluator.new();
    my $actions = LinguaActions.new(:evaluator($evaluator));
    my $parsed = Lingua.parse($code, :actions($actions));

    error('Error: parse failed') unless $parsed;

    my $tree = $parsed.made;
    $tree = LinguaOptimizer.new.optimize($tree)
        unless $no-optimize;

    dd $tree if $ast;
    $evaluator.eval($tree);
    dd $evaluator.var if $vars;
}

sub error($message) {
    note $message;
    exit 1;
}
```

The `dd` calls moved from the evaluator to the script, where they are guarded by the flags, and the `eval` method became as short as it should be:

```raku-static
method eval(ASTNode $top) {
    self.eval-node($_) for $top.statements;
}
```

By default, the interpreter is now completely silent and only prints what the program asks it to print. Also notice the comments that start with `#=`. Raku collects them and generates the usage message without a single line of our code:

```
$ ./lingua
Usage:
  ./lingua [--ast] [--vars] [--no-optimize] <filename>

    <filename>       a program in Lingua
    --ast            dump the syntax tree
    --vars           dump the variable storage
    --no-optimize    skip the optimisation pass
```

The `--no-optimize` flag makes it easy to repeat the experiment from Chapter 13 and to see with your own eyes how the optimiser transforms the tree of a program — compare the two dumps:

```
$ ./lingua --ast --no-optimize program.lng
$ ./lingua --ast program.lng
```

A dozen lines of a signature, and our compiler behaves like a grown-up command-line tool.

{% include nav.html %}
