---
title: AST for expressions
---

{% include menu.html %}

Consider a simple program:

```raku-static
my a;
a = 2 + 3;
```

The first line is a variable declaration, the second is an assignment. There is one more action here: addition, which also has to be represented by an AST node. Let us build the following tree:

![diagram](/assets/creating-a-compiler-in-raku/image8.png)

As you may notice, the new node is called `AST::MathOperations` and it contains two arrays, for operators and operands.

In the simplest example, there will be only one operator and two operands, but the same object is also suitable for longer sequences, say , where all operators have the same precedence level. This solution helps to reduce the number of the AST nodes and also simplifies the tree walk on the next stage.

So, here’s the class:

```raku-static
class AST::MathOperations is ASTNode {
    has Str @.operators;
    has ASTNode @.operands;
}
```

The operators are stored as strings; the operands are other AST nodes. Embedding AST generation to the `LinguaActions` class has more deletions than insertions. We have to remove all the `operation` subroutines. They do actual addition, multiplication, etc., and we do not need that in the AST. All those real actions will be done on a later stage of traversing the tree.

The philosophy of having a few multi-variants of the `expr` action, on one side, makes the implementation more difficult, as you have to think how the AST node will be propagating to the top. On the other side, you can split it into even smaller actions and decide whether you have to emit an `AST::MathOperations` or an `AST::NumberValue` depending on the presence of the `$<op>` key in the match object. In other words, if there are operators in the expression, use `AST::MathOperations`, otherwise, it generates a number stored in the attribute of an `AST::NumberValue` node.

```raku-static
multi method expr($/ where $<expr> && !$<op>) {
    $/.make($<expr>[0].made);
}

multi method expr($/ where $<expr> && $<op>) {
    $/.make(AST::MathOperations.new(
        operators => ($<op>.map: ~*),
        operands => ($<expr>.map: *.made)
    ));
}

multi method expr($/ where $<expression>) {
    $/.make($<expression>.made);
}
```

Our implementation is not a standard AST tree for arithmetical expressions. Let us examine a simple expression with operators of different precedence:

```raku-static
my x = 2 + 3 * 4 / 5 - 6;
```

In other books on compiler design and parsing, you would most likely meet a tree where each node represents a single arithmetical operation with two operands, such as shown on the left on the diagram below.

![diagram](/assets/creating-a-compiler-in-raku/image9.png)

The tree for our compiler is shown on the right. Each node can take any number of operands, and the tree is much more compact: in this example, there are two times fewer nodes comparing to the left version. If the node has three operands, it should always have two operators, which you will later put between the operands.

After the tree is built, the `$top` variable in the `TOP` method will contain the following data structure:

```raku-static
AST::TOP $top = AST::TOP.new(
  statements => Array[ASTNode].new(
    AST::ScalarDeclaration.new(
      variable-name => "x",
      value => AST::MathOperations.new(
        operators => Array[Str].new(
          "+",
          "-"
        ),
        operands => Array[ASTNode].new(
          AST::NumberValue.new(
            value => 2
          ),
          AST::MathOperations.new(
            operators => Array[Str].new(
              "*",
              "/"
            ),
            operands => Array[ASTNode].new(
              AST::NumberValue.new(
                value => 3
              ),
              AST::NumberValue.new(
                value => 4
              ),
              AST::NumberValue.new(
                value => 5
              )
            )
          ),
          AST::NumberValue.new(
            value => 6
          )
        )
      )
    )
  )
)
```

{% include nav.html %}
