---
title: Tested programs
---

{% include menu.html %}

Every complete Raku program in these books is **compiled and run at build time** under two compilers — [Rakudo](https://rakudo.org) (the reference implementation) and [Raku++](https://github.com/ash/rakupp) (the engine that runs code in your browser via [Raku.js](https://raku.online)). A program gets a **Run** button only when it runs under Rakudo *and* Raku++ reproduces the same output.
Of **1341** Raku programs across the books: **349** run in the browser, **908** are illustrative fragments (no Run button), **29** need a local environment (files or the command line), **28** use concurrency the single-threaded in-browser engine can't run, and **27** are valid programs the in-browser engine cannot run correctly yet.

## Programs that need a local environment

These are complete, valid Raku programs, but they read the filesystem, spawn processes, or use the command line — things the sandboxed in-browser engine has no access to. They run fine on your own computer.

| Program | Book | Why |
|---------|------|-----|
| [Renaming files](/raku-one-liners/renaming-files) | Raku One-Liners | reads the local environment |
| [Merging files horizontally](/raku-one-liners/merging-files-horizontally) | Raku One-Liners | reads the local environment |
| [Reversing a file](/raku-one-liners/reversing-a-file) | Raku One-Liners | reads the local environment |
| [All the stars of Raku](/raku-one-liners/all-the-stars-of-raku) | Raku One-Liners | reads the local environment |
| [18. Finding duplicate texts](/using-raku/text-analysis/finding-duplicate-texts) | Using Raku | reads the local environment |
| [92. Sleep Sort](/using-raku/sleep-sort) | Using Raku | reads the local environment |
| [94. Parallel file processing](/using-raku/parallel-file-processing) | Using Raku | reads the local environment |
| [95. The cat utility](/using-raku/the-cat-utility) | Using Raku | reads the local environment |
| [97. Reading directory content](/using-raku/reading-directory-content) | Using Raku | reads the local environment |
| [Creating a Simple Translator](/creating-a-compiler-in-raku/creating-a-simple-translator) | Creating a Compiler in Raku | reads the local environment |
| [Grammar](/creating-a-compiler-in-raku/grammar) | Creating a Compiler in Raku | reads the local environment |
| [Test runner](/creating-a-compiler-in-raku/test-runner) | Creating a Compiler in Raku | reads the local environment |
| [Twigils](/perl-6-at-a-glance/variables/twigils) | Perl 6 at a Glance | reads the local environment |
| [Frequently used special variables](/perl-6-at-a-glance/variables/frequently-used-special-variables) | Perl 6 at a Glance | reads the local environment |
| [An example](/perl-6-at-a-glance/promises/an-example) | Perl 6 at a Glance | reads the local environment |
| [Files](/perl-6-at-a-glance/files) | Perl 6 at a Glance | reads the local environment |

## Programs that use concurrency

These use promises or threads. The in-browser engine (Raku.js) is single-threaded, so real parallelism deadlocks — run these on your own computer.

| Program | Book | Why |
|---------|------|-----|
| [14. The longest common substring](/using-raku/text-analysis/the-longest-common-substring) | Using Raku | uses concurrency (promises/threads) |
| [17. The longest palindrome](/using-raku/text-analysis/the-longest-palindrome) | Using Raku | uses concurrency (promises/threads) |
| [91. Setting timeouts](/using-raku/setting-timeouts) | Using Raku | uses concurrency (promises/threads) |
| [April](/perl-6-calendar-2019/april) | Perl 6 Calendar 2019 | uses concurrency (promises/threads) |
| [Read and write](/perl-6-at-a-glance/channels/read-and-write) | Perl 6 at a Glance | uses concurrency (promises/threads) |
| [The list method](/perl-6-at-a-glance/channels/the-list-method) | Perl 6 at a Glance | uses concurrency (promises/threads) |
| [Beyond scalars](/perl-6-at-a-glance/channels/beyond-scalars) | Perl 6 at a Glance | uses concurrency (promises/threads) |
| [The closed method](/perl-6-at-a-glance/channels/the-closed-method) | Perl 6 at a Glance | uses concurrency (promises/threads) |
| [Basics](/perl-6-at-a-glance/promises/basics) | Perl 6 at a Glance | uses concurrency (promises/threads) |
| [start](/perl-6-at-a-glance/promises/start) | Perl 6 at a Glance | uses concurrency (promises/threads) |
| [in and at](/perl-6-at-a-glance/promises/in-and-at) | Perl 6 at a Glance | uses concurrency (promises/threads) |
| [anyof and allof](/perl-6-at-a-glance/promises/anyof-and-allof) | Perl 6 at a Glance | uses concurrency (promises/threads) |

## Programs the in-browser engine can’t run yet

These are complete, valid Raku programs, but Raku++ errors or prints something different from Rakudo — a gap to close in the browser engine. Each page still shows the program’s expected output.

| Program | Book | Why |
|---------|------|-----|
| [All the stars of Raku](/raku-one-liners/all-the-stars-of-raku) | Raku One-Liners | Raku++ output differs |
| [The second test](/raku-one-liners/the-second-test) | Raku One-Liners | Raku++ output differs |
| [10. DNA-to-RNA transcription](/using-raku/modifying-string-data/dna-to-rna-transcription) | Using Raku | Raku++ output differs |
| [32. Generating random numbers](/using-raku/random-numbers/generating-random-numbers) | Using Raku | Raku++ output differs |
| [36. Standard deviation](/using-raku/mathematical-problems/standard-deviation) | Using Raku | Raku++ output differs |
| [38. Monte Carlo method](/using-raku/mathematical-problems/monte-carlo-method) | Using Raku | Raku++ error (non-deterministic) |
| [78. Separate digits and letters](/using-raku/substitutions-with-regexes/separate-digits-and-letters) | Using Raku | Raku++ output differs |
| [81. Pig Latin](/using-raku/substitutions-with-regexes/pig-latin) | Using Raku | Raku++ output differs |
| [82. Simple string compressor](/using-raku/substitutions-with-regexes/simple-string-compressor) | Using Raku | Raku++ output differs |
| [84. Decode Roman numerals](/using-raku/using-grammars/decode-roman-numerals) | Using Raku | Raku++ output differs |
| [86. Basic calculator](/using-raku/using-grammars/basic-calculator) | Using Raku | Raku++ output differs |
| [!, not](/perl-6-at-a-glance/prefixes/not) | Perl 6 at a Glance | Raku++ output differs |
| [Method postfixes](/perl-6-at-a-glance/method-postfixes) | Perl 6 at a Glance | Raku++ output differs |
| [before, after](/perl-6-at-a-glance/universal-comparison-operators/before-after) | Perl 6 at a Glance | Raku++ output differs |
| [Modules](/perl-6-at-a-glance/modules) | Perl 6 at a Glance | Raku++ output differs |
| [Private (closed) methods](/perl-6-at-a-glance/private-closed-methods) | Perl 6 at a Glance | Raku++ output differs |
| [Unicode](/perl-6-at-a-glance/unicode) | Perl 6 at a Glance | Raku++ output differs |

## Verified-runnable programs

<details><summary><strong>Raku One-Liners</strong> — 23 programs</summary>

<div markdown="1">

* [Grepping multiples of 3 and 5](/raku-one-liners/grepping-multiples-of-3-and-5)
* [Generating random integers](/raku-one-liners/generating-random-integers)
* [Testing palindromic numbers](/raku-one-liners/testing-palindromic-numbers)
* [Adding up even Fibonacci numbers](/raku-one-liners/adding-up-even-fibonacci-numbers)
* [Playing with Fibonacci numbers](/raku-one-liners/playing-with-fibonacci-numbers)
* [Distance between two points](/raku-one-liners/distance-between-two-points)
* [Playing with prime numbers](/raku-one-liners/playing-with-prime-numbers)
* [Using map and Seq to compute the value of π](/raku-one-liners/using-map-and-seq-to-compute-the-value-of)
* [Computing totals](/raku-one-liners/computing-totals)
* [Sum of the numbers equal to the sum of factorials of digits](/raku-one-liners/sum-of-the-numbers-equal-to-the-sum-of-factorials-of-digits)
* [Generating random passwords](/raku-one-liners/generating-random-passwords)
* [The joy of Unicode](/raku-one-liners/the-joy-of-unicode)
* [What’s the date today?](/raku-one-liners/whats-the-date-today)
* [How many days in the century match the condition?](/raku-one-liners/how-many-days-in-the-century-match-the-condition)
* [Another solution of the same prob- lem](/raku-one-liners/another-solution-of-the-same-prob-lem)
* [More on X, .., and …](/raku-one-liners/more-on-x-and)
* [Reduction operator](/raku-one-liners/reduction-operator)
* [All the stars of Raku](/raku-one-liners/all-the-stars-of-raku)
* [The EVAL routine](/raku-one-liners/the-eval-routine)
* [The first test](/raku-one-liners/the-first-test)
* [The second test](/raku-one-liners/the-second-test)
* [Tips and ideas for the Raku Golf code](/raku-one-liners/tips-and-ideas-for-the-raku-golf-code)
* [What’s behind 0.1 + 0.2](/raku-one-liners/whats-behind-0-1-0-2)

</div>
</details>

<details><summary><strong>Using Raku</strong> — 59 programs</summary>

<div markdown="1">

* [How to debug programs](/using-raku/how-to-debug-programs)
* [1. Hello, World!](/using-raku/using-strings/hello-world)
* [2. Greet a person](/using-raku/using-strings/greet-a-person)
* [3. String length](/using-raku/using-strings/string-length)
* [5. Reverse a string](/using-raku/modifying-string-data/reverse-a-string)
* [6. Removing blanks from a string](/using-raku/modifying-string-data/removing-blanks-from-a-string)
* [8. Incrementing filenames](/using-raku/modifying-string-data/incrementing-filenames)
* [9. Random passwords](/using-raku/modifying-string-data/random-passwords)
* [11. Caesar cipher](/using-raku/modifying-string-data/caesar-cipher)
* [12. Plural endings](/using-raku/text-analysis/plural-endings)
* [19. π](/using-raku/using-numbers/page)
* [20. Factorial!](/using-raku/using-numbers/factorial)
* [21. Fibonacci numbers](/using-raku/using-numbers/fibonacci-numbers)
* [22. Print squares](/using-raku/using-numbers/print-squares)
* [23. Powers of two](/using-raku/using-numbers/powers-of-two)
* [24. Odd and even numbers](/using-raku/using-numbers/odd-and-even-numbers)
* [25. Compare numbers approximately](/using-raku/using-numbers/compare-numbers-approximately)
* [27. Prime numbers](/using-raku/using-numbers/prime-numbers)
* [28. List of prime numbers](/using-raku/using-numbers/list-of-prime-numbers)
* [29. Prime factors](/using-raku/using-numbers/prime-factors)
* [30. Reducing a fraction](/using-raku/using-numbers/reducing-a-fraction)
* [31. Divide by zero](/using-raku/using-numbers/divide-by-zero)
* [32. Generating random numbers](/using-raku/random-numbers/generating-random-numbers)
* [33. Neumann’s random generator](/using-raku/random-numbers/neumanns-random-generator)
* [34. Histogram of random numbers](/using-raku/random-numbers/histogram-of-random-numbers)
* [35. Distance between two points](/using-raku/mathematical-problems/distance-between-two-points)
* [39. Unicode digits](/using-raku/numbers-and-strings/unicode-digits)
* [41. Binary to integer](/using-raku/numbers-and-strings/binary-to-integer)
* [42. Integer as binary, octal, and hex](/using-raku/numbers-and-strings/integer-as-binary-octal-and-hex)
* [43. Sum of digits](/using-raku/numbers-and-strings/sum-of-digits)
* [44. Bit counter](/using-raku/numbers-and-strings/bit-counter)
* [45. Compose the largest number](/using-raku/numbers-and-strings/compose-the-largest-number)
* [46. Convert to Roman numerals](/using-raku/numbers-and-strings/convert-to-roman-numerals)
* [48. Swap two values](/using-raku/manipulating-lists-and-arrays/swap-two-values)
* [49. Reverse a list](/using-raku/manipulating-lists-and-arrays/reverse-a-list)
* [50. Rotate a list](/using-raku/manipulating-lists-and-arrays/rotate-a-list)
* [51. Randomise an array](/using-raku/manipulating-lists-and-arrays/randomise-an-array)
* [52. Incrementing array elements](/using-raku/manipulating-lists-and-arrays/incrementing-array-elements)
* [53. Adding up two arrays](/using-raku/manipulating-lists-and-arrays/adding-up-two-arrays)
* [55. Sum of the elements of an array](/using-raku/information-retrieval/sum-of-the-elements-of-an-array)
* [56. Average of an array](/using-raku/information-retrieval/average-of-an-array)
* [58. Is an element in a list?](/using-raku/information-retrieval/is-an-element-in-a-list)
* [59. First odd number](/using-raku/information-retrieval/first-odd-number)
* [62. Finding unique elements](/using-raku/information-retrieval/finding-unique-elements)
* [63. Minimum and maximum](/using-raku/information-retrieval/minimum-and-maximum)
* [64. Increasing sequences](/using-raku/information-retrieval/increasing-sequences)
* [65. Passing arrays to subroutines](/using-raku/working-with-subroutines/passing-arrays-to-subroutines)
* [66. Variadic parameters in a sub](/using-raku/working-with-subroutines/variadic-parameters-in-a-sub)
* [70. Product table](/using-raku/multi-dimensional-data/product-table)
* [71. Pascal triangle](/using-raku/multi-dimensional-data/pascal-triangle)
* [72. Count vowels in a word](/using-raku/regex-matching/count-vowels-in-a-word)
* [76. Double each character](/using-raku/substitutions-with-regexes/double-each-character)
* [77. Remove duplicated words](/using-raku/substitutions-with-regexes/remove-duplicated-words)
* [80. Increase digits by one](/using-raku/substitutions-with-regexes/increase-digits-by-one)
* [86. Basic calculator](/using-raku/using-grammars/basic-calculator)
* [87. Current date and time](/using-raku/current-date-and-time)
* [88. Formatted date](/using-raku/formatted-date)
* [89. Datetime arithmetic](/using-raku/datetime-arithmetic)
* [90. Leap years](/using-raku/leap-years)

</div>
</details>

<details><summary><strong>Creating a Compiler in Raku</strong> — 6 programs</summary>

<div markdown="1">

* [Functions take expressions](/creating-a-compiler-in-raku/functions-take-expressions)
* [Escaping quotes](/creating-a-compiler-in-raku/escaping-quotes)
* [Variable interpolation](/creating-a-compiler-in-raku/variable-interpolation)
* [Strings](/creating-a-compiler-in-raku/tests/strings-2)
* [print](/creating-a-compiler-in-raku/built-in-functions/print)
* [Eliminating dead branches](/creating-a-compiler-in-raku/eliminating-dead-branches)

</div>
</details>

<details><summary><strong>Perl 6 Calendar 2019</strong> — 11 programs</summary>

<div markdown="1">

* [January](/perl-6-calendar-2019/january)
* [February](/perl-6-calendar-2019/february)
* [March](/perl-6-calendar-2019/march)
* [May](/perl-6-calendar-2019/may)
* [June](/perl-6-calendar-2019/june)
* [July](/perl-6-calendar-2019/july)
* [August](/perl-6-calendar-2019/august)
* [September](/perl-6-calendar-2019/september)
* [October](/perl-6-calendar-2019/october)
* [November](/perl-6-calendar-2019/november)
* [December](/perl-6-calendar-2019/december)

</div>
</details>

<details><summary><strong>Perl 6 at a Glance</strong> — 51 programs</summary>

<div markdown="1">

* [Hello, World!](/perl-6-at-a-glance/hello-world)
* [Sigils](/perl-6-at-a-glance/variables/sigils)
* [Introspection](/perl-6-at-a-glance/variables/introspection)
* [Frequently used special variables](/perl-6-at-a-glance/variables/frequently-used-special-variables)
* [Typed variables](/perl-6-at-a-glance/built-in-types/typed-variables)
* [Bool](/perl-6-at-a-glance/built-in-types/bool)
* [Int](/perl-6-at-a-glance/built-in-types/int)
* [Str](/perl-6-at-a-glance/built-in-types/str)
* [Array](/perl-6-at-a-glance/built-in-types/array)
* [!, not](/perl-6-at-a-glance/prefixes/not)
* [?, so](/perl-6-at-a-glance/prefixes/so)
* [Postfixes](/perl-6-at-a-glance/postfixes)
* [Method postfixes](/perl-6-at-a-glance/method-postfixes)
* [div, mod](/perl-6-at-a-glance/numerical-operators/div-mod)
* [+<, +>](/perl-6-at-a-glance/numerical-operators/page-4)
* [String operators](/perl-6-at-a-glance/string-operators)
* [lt, gt, le, ge](/perl-6-at-a-glance/string-operators/lt-gt-le-ge)
* [Universal comparison operators](/perl-6-at-a-glance/universal-comparison-operators)
* [before, after](/perl-6-at-a-glance/universal-comparison-operators/before-after)
* [List operators](/perl-6-at-a-glance/list-operators)
* [|, &, ^](/perl-6-at-a-glance/junction-operators/page-7)
* [Shortcut operators](/perl-6-at-a-glance/shortcut-operators)
* [min, max](/perl-6-at-a-glance/other-infix-operators/min-max)
* [:](/perl-6-at-a-glance/other-infix-operators/page-8)
* [Negation](/perl-6-at-a-glance/meta-operators/negation)
* [Reverse operator](/perl-6-at-a-glance/meta-operators/reverse-operator)
* [Reduction](/perl-6-at-a-glance/meta-operators/reduction)
* [Cross-operators](/perl-6-at-a-glance/meta-operators/cross-operators)
* [Zip meta-operators](/perl-6-at-a-glance/meta-operators/zip-meta-operators)
* [Hyper-operators](/perl-6-at-a-glance/hyper-operators)
* [Subroutines, or subs](/perl-6-at-a-glance/subroutines-or-subs)
* [Non-value argument passing](/perl-6-at-a-glance/subroutines-or-subs/non-value-argument-passing)
* [Optional parameters](/perl-6-at-a-glance/subroutines-or-subs/optional-parameters)
* [Default values](/perl-6-at-a-glance/subroutines-or-subs/default-values)
* [Slurpy parameters and flattening](/perl-6-at-a-glance/subroutines-or-subs/slurpy-parameters-and-flattening)
* [Nested subs](/perl-6-at-a-glance/subroutines-or-subs/nested-subs)
* [Anonymous subs](/perl-6-at-a-glance/subroutines-or-subs/anonymous-subs)
* [Lexical variables](/perl-6-at-a-glance/variables-and-signatures/lexical-variables)
* [Dynamic variables](/perl-6-at-a-glance/variables-and-signatures/dynamic-variables)
* [Anonymous code blocks](/perl-6-at-a-glance/anonymous-code-blocks)
* [Placeholders](/perl-6-at-a-glance/placeholders)
* [Function overloading](/perl-6-at-a-glance/function-overloading)
* [Class methods](/perl-6-at-a-glance/class-methods)
* [Multiple inheritance](/perl-6-at-a-glance/multiple-inheritance)
* [Private (closed) methods](/perl-6-at-a-glance/private-closed-methods)
* [Submethods](/perl-6-at-a-glance/submethods)
* [Constructors](/perl-6-at-a-glance/constructors)
* [The $/ object](/perl-6-at-a-glance/the-object)
* [Actions](/perl-6-at-a-glance/actions)
* [Unicode](/perl-6-at-a-glance/unicode)
* [Whatever (*)](/perl-6-at-a-glance/whatever)

</div>
</details>

