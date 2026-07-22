---
title: Evaluating AST
---

{% include menu.html %}

In the previous chapter, we learned how to transform an input program to an AST. The tree only holds information about the real essence of the program, removing, for example, all the comments from the source code.

During the whole previous chapter, the output of the compiler was a tree. We could see what the program thinks it has to do, but we did not actually see the result of that work. In this chapter, we will walk along the AST and execute the tasks that it represents.

{% include nav.html %}
