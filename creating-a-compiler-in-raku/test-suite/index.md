---
title: Test suite
---

{% include menu.html %}

The compiler becomes bigger and bigger, and we are going to add more syntax to the Lingua language. It is a good time to make a pause in the compiler development and ensure some stability. In this chapter, we will create a test suite, which will allow us to find problems in the implementation and prevent new bugs when extending the language.

The test suite of Raku itself is a set of files written in Raku. They use the Test module, similar to how we did in Chapter 3. This is great but to allow those tests to run, you need a compiler that can parse it. For our purpose, this approach is an overhead, so let us come up with our own solution.

Our goal is to test all features of Lingua, so we have to create test examples for variable declaration—both scalars, and arrays, and hashes,—assignments, for different expressions with different operators, string interpolation, etc. In the following chapters, we will add conditionals and functions, so we will create tests for them too.

What did we do in the previous chapters to see if the compiler works correctly? We looked at the AST, at the content of the variable storage, and at the output. All three parts tell us about the health of the compiler. Testing all of them is a difficult task. Let us restrict ourselves and only check what the programs output. The structure of the syntax tree is not that important for the end user, so we can check it manually from time to time if needed. Variable storage is more important, but we always can print the variables that we expect it to contain, and thus convert the second task into checking the output.

So, our final goal is to make the way to describe our desired output, and create a program that runs test examples and compares the output with our correct values.

{% include nav.html %}
