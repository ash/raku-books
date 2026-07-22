---
title: Optimising the AST
---

{% include menu.html %}

Our compiler works in three stages: the grammar parses the source code, the actions build the AST, and the evaluator walks the tree and executes it. In this chapter, we squeeze one more stage in between the last two: optimisation. An optimiser transforms the tree into another tree, which behaves exactly the same but is smaller and cheaper to evaluate. Besides being useful, writing an optimiser is a very good exercise in understanding ASTs: this time, we will not only read the tree but rewrite it.

Why bother? Consider an expression such as `2 + 3 * 4` in the body of a function or a loop. The evaluator computes it again on every iteration and on every call, although the result is always 14 and is known before the program even starts. So, it would be wise to compute it once, at compile time.

{% include nav.html %}
