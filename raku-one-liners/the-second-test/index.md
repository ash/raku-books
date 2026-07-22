---
title: The second test
---

{% include menu.html %}

Let’s solve another Golf task and print the first 30 Fibonacci numbers, one at a line. We have to use as few characters in the code as possible.

The first approach is rather wordy (even when using `^31` instead of `0..30`, it needs 33 characters):

```raku
.say for (0, 1, * + * ... *)[^31]
```

There is some room that allows compression. Of course, the first and the most obvious thing is to remove spaces (remaining 28 characters):

```raku
.say for (0,1,*+*...*)[^31]
```

Another interesting trick is to use the `>>` meta-operator to call the `say` method on each element of the sequence. It compresses the code further to 24 characters:

```raku
(0,1,*+*...*)[^31]>>.say
```

At this moment, we can employ some Unicode and gain three more characters (21 left):

```raku
(0,1,*+*…*)[^31]».say
```

Looks compact already, but there are still some options to try. Let us get rid of the explicit slicing, and try to stop the sequence at the last element:

```raku
(0,1,*+*…*>514229)».say
```

The code became longer (23 characters), but we do not need an exact number 514 229 here. It is enough to give some close number that is bigger than the 29th and smaller than the 30th element of the sequence. For example, it can be 823 543, which is 7 powered 7. Write it down using superscripts (19 characters):

```raku
(0,1,*+*…*>7⁷)».say
```

Finally, it is possible to make it one character less by using another Unicode character representing 800 000 in a single character. Not every (if any) font can display something visually attractive, but Raku takes the character with no complains:

```raku-static
(0,1,*+*…*>)».say
```

These 18 characters is one character longer than the top result at the code-golf.io site. I have a feeling that you could gain another character by replacing the first two elements of the sequence with `^2`, but that does not work in current Rakudo, and you have to return a character to flatten the list: `|^2`, which makes the solution 18 characters long again.

The desire is to remove the `*>` part in the condition to stop the sequence and replace it with a fixed number. Unfortunately, there’s no way to express 832 040 with powers of the numbers between 1 and 90. Would that be possible, we could use a superscript to calculate the number.

Another idea is to use a regex, but we need at least four characters here, which does not help:

```raku-nobrowser
(0,1,*+*…/20/)».say
```

But let me stop here and let you to think about it further.

Notice that you should not rely on printing within the `>>` operation in a reallife code, as printing is a side effect and future Raku compilers may execute it concurrently, so you are not guaranteed to get the results in correct order.

{% include nav.html %}
