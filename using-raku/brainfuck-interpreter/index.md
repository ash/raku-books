---
title: 100. Brainfuck interpreter
---

{% include menu.html %}

*Create the interpreter for the Brainfuck language.*

Brainfuck is an esoteric programming language that has a small set of instructions, each of them a single punctuation character.

It is assumed that the Brainfuck program has built-in data memory, which is an array of integers, and a pointer to the currently selected item. The two instructions, `+` and `-`, increment and decrement the current element. The `<` and `>` instructions move the data pointer one position to the left or to the right.

Another two instructions, `.` and `,`, either print the current element using its values as the ASCII codepoint (in theory, it can be Unicode) or read a character from the standard input and put its numeric value to the current element of the data array.

Finally, `[` and `]` create loops. If when the program reads the closing bracket character, the current data element is not zero, the program returns to the corresponding opening bracket. In the case the program reads an opening bracket and the current data element is zero, the whole block between the two matching brackets is skipped. This option can also be used for embedding comments.

All other characters are ignored. This gives the ability to separate the program instructions with spaces or newlines, as well as to add comments just next to the main code. The comments should simply not include the main characters used as the code instructions.

Online, you can find many examples of the Brainfuck code. We’ll test our program on the following ‘Hello World!’ program:

```
++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---
.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.
```

Now, we are ready to create the interpreter of Brainfuck in Raku.

First, read the source code to the `$program` variable, and pass it to the main interpreter subroutine:

```raku-static
my $program = $*IN.slurp;
brainfuck($program);
```

The parser first creates the containers it needs for the process: `@program` holds the program as an array of characters; the `$program_pointer` is set to the beginning of it; `@data_memory` keeps the data, and its current position is also set to 0 via `$data_pointer`.

```raku-static
sub brainfuck($program) {
    my @program = $program.comb('');
    my $program_pointer = 0;
    my @data_memory;
    my $data_pointer = 0;
```

Now, iterate over the program instructions.

```raku-static
    while $program_pointer < @program.elems {
```

At this point of the main loop, the `@program[$program_pointer]` element contains the current program instruction. We are using the `given`—`when` block to understand the meaning of it and make an action. The first four commands are straightforward:

```raku-static
        given @program[$program_pointer] {
            when '>' {$data_pointer++}
            when '<' {$data_pointer--}
            when '+' {@data_memory[$data_pointer]++}
            when '-' {@data_memory[$data_pointer]--}
```

Let’s skip the comma command for now and move on to the input dot. The input command is using the `@data_memory` array and the `chr` method to translate codepoints to characters.

```raku-static
            when '.' {
                print @data_memory[$data_pointer].chr
            }
```

Finally, the loop commands `[` and `]`. Their behaviour depends on the value of the current data element `@data_memory[$data_pointer]`. If the condition is met (i. e., if the current element is zero for `[` and non-zero for `]`), the `$program_pointer` must be moved to the position of the matching bracket.

To simplify the program, the code to find balancing brackets is placed to separate functions, `_move_forward`, and `_move_back`. They modify the value of the program pointer, which is passed as an argument.

```raku-static
            when '[' {
                $program_pointer =
                    _move_forward(@program, $program_pointer)
                unless @data_memory[$data_pointer];
            }
            when ']' {
                $program_pointer =
                    _move_back(@program, $program_pointer)
                if @data_memory[$data_pointer];
            }
        }
```

All other instructions, which are not listed in the `when` clauses, are simply ignored. After the current instruction has been processed, the program pointer is moved to the next position:

```raku-static
        $program_pointer++;
    }
}
```

Finally, here is the code for the functions searching balancing brackets. They move either forward or backwards and count the opening and closing brackets. The `$level` variable is increased if the program finds the bracket, which is not the correct pair.

```raku-static
sub _move_back(@program, $program_pointer is copy) {
    my $level = 1;
    while $level && $program_pointer >= 0 {
        $program_pointer--;
        given @program[$program_pointer] {
            when '[' {$level--}
            when ']' {$level++}
        }
    }
    return $program_pointer - 1;
}

sub _move_forward(@program, $program_pointer is copy) {
    my $level = 1;
    while $level && $program_pointer < @program.elems {
        $program_pointer++;
        given @program[$program_pointer] {
            when '[' {$level++}
            when ']' {$level--}
        }
    }
    return $program_pointer - 1;
}
```

The subroutines use the same approach with the `given`—`when` keywords for dealing with command characters as in the main loop.

To prevent infinite loops in case of the incorrect program, both subs check if the `$program_pointer` reaches the beginning or end of the program. Notice that because the `$program_pointer` is modified inside the subs, it is declared as `is` `copy` in the signatures of the subs. The return value is intentionally decremented by one to compensate the subsequent increment of it in the main loop: `$program_pointer++`.

The interpreter is complete. Save the ‘Hello World!’ program in a file and pass it in the command line:

```
$ raku brainfuck.rk < helloworld.bf
Hello World!
```

As an exercise, modify the interpreter so that it understands the `,` command. You need to update the `given`—`when` list in the main loop with the code that reads the character from the input:

```raku-static
when ',' {@data_memory[$data_pointer] = $*IN.getc.?ord}
```

The `$*IN.getc` returns `Nil` when there are no more characters in the input. Try to catch this situation to avoid filling the data memory with empty data. Here is a test program that copies the input to the output:

```
>+[[>],.-------------[+++++ +++++ +++[<]]>]<<[<]>>[.>]
```

Another useful modification would be error handling. There are a few places in the program where increments or decrements in one of the pointers may go out of the array ranges. Add the code that checks that to display an error message. To make the process easier, use some simple debugging code like the one below to visualise the position of the program pointer and data state at each iteration of the main loop:

```raku-static
say $program;
say ' ' x $program_pointer ~ '^';
say @data_memory[0..$data_pointer - 1] ~ ' [' ~
    @data_memory[$data_pointer] ~ '] ' ~
    @data_memory[$data_pointer + 1..*];
```

{% include nav.html %}
