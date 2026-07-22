---
title: Computing totals
---

{% include menu.html %}

In this section, we’ll see a one-liner that calculates totals for the columns of a table.

Here’s some sample data in a file:

```
100.20  303.50 150.25
130.44 1505.12  36.41
200.12  305.60  78.12
```

And here’s the code that prints three numbers—totals for each column:

```raku-static
put [Z+] lines.map: *.words
```

The program prints the numbers that we need:

```
430.76 2114.22 264.78
```

We know that bare `lines` is the same as `$*IN.lines`, so `lines.map` iterates over all the lines in the input stream. Each line is then split into words— substrings separated by whitespaces.

The part of the job that parses input data is complete. We have got a number of sequences corresponding to the lines of input data. For our sample file, these are the following:

```
(("100.20", "303.50", "150.25").Seq, ("130.44", "1505.12",
"36.41").Seq, ("200.12", "305.60", "78.12").Seq).Seq
```

Now, add up every first element, every second element, etc. The combination of the reduction operator and the zip meta-operators does all the work with only four characters: `[Z+]`.

At this point, we have a reduced sequence:

```
(430.76, 2114.22, 264.78).Seq
```

The last trivial step is to print the values using the `put` routine. If you did the homework earlier, then you know that `say` uses the `gist` method (which adds parentheses around a sequence) to visualise the result, while `put` simply prints the values using the `Str` method.

Let us add a few more characters to the script to demonstrate how you can skip the first column that, for example, contains the names of the months:

```
Jan 100.20  303.50 150.25
Feb 130.44 1505.12  36.41
Mar 200.12  305.60  78.12
```

All you need is to make a slice and select all columns except the first one:

```raku
put 'Total ', [Z+] lines.map: *.words[1..*]
```

As you see, we even don’t need to count the columns ourselves. The `1..*` range makes that job for us.

{% include nav.html %}
