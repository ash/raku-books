---
title: Control Flow
---

{% include menu.html %}

We started Chapter 8 with an attempt to implement the `if` keyword. It was tricky to do so in the translator that executes the code line by line. Introducing the AST allows us to parse the program without executing it, so we can first build the node and only run the code behind it if the condition is true.

{% include nav.html %}
