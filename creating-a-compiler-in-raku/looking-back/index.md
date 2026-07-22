---
title: Looking back
---

{% include menu.html %}

The journey is over, so let us look back at the road. We started with a grammar of half a dozen rules that could parse (and immediately execute) three kinds of statements. Step by step, the language gained numbers of all shapes, strings with interpolation, arrays and hashes, arithmetic and Boolean expressions, conditions, loops, and functions, both built-in and user-defined, including recursive ones.

The compiler grew up together with the language. Inline actions became a separate class, direct execution was replaced with an abstract syntax tree, and then the evaluator and the optimiser joined the pipeline. Parse, build the tree, transform it, execute: this is the classical shape of a real compiler. Every stage of it now lives in its own module, and the test suite keeps an eye on all of them.

And still, the whole compiler is just a few hundred lines of Raku code. This compactness is not an accident. Grammars, multiple dispatch, junctions, and the `where` clauses let the code say what it means directly, and most of our changes were measured in lines rather than screens.

The Lingua language will happily accept your extensions. Here are a few ideas to try:

more built-in functions: string manipulation, mathematics, input from the user;

an `elsif` clause and the Boolean `not` operator;

string operators, starting with concatenation;

arrays and hashes as function arguments and return values;

more optimisations, starting with the elimination of never-running loops;

an interactive REPL that compiles and executes the program line by line.

A note on the file names. Modern Rakudo prefers module files with the .rakumod extension, and in the repository, the modules are already renamed. The text of this book keeps the original .pm names, so do not be surprised by the difference. The test runner in the repository was also rewritten to use the `Test` module, while its idea remained the same.

The complete source code, with a git history that follows the chapters of this book, is available in the repository. Thank you for reading, and have fun creating your own languages!

{% include nav.html %}
