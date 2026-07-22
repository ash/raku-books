---
title: 18. Finding duplicate texts
---

{% include menu.html %}

*Find duplicate fragments in the same text.*

This task was dictated by the practical need when I realised that I used the same phrases in different parts of the text of this book. Some of them, like Hello, World!, are unavoidable, but it would be a great help to find the rest.

Here is the full solution, which scans the text from standard input and finds the sequences of N words which appear more than once in the text.

```raku-local
my $text = $*IN.slurp;
$text .= lc;
$text ~~ s:g/\W+/ /;
my $length = $text.chars;

my %phrases;
my $start = 0;
while $text ~~ m:c($start)/(<< [\w+] ** 5 %% \s >>) .+ $0/ {
    $start = $0.from + 1;
    %phrases{$0}++;

    print (100 * $start / $length).fmt('%i%% ');
    say $0;
}

say "\nDuplicated strings:";

for %phrases.keys.sort({%phrases{$^b} <=> %phrases{$^a}}) {
    say "$_ = " ~ %phrases{$_} + 1;
}
```

The program is relatively complicated, so let us examine it bit by bit.

First, the program reads the input using the `$*IN.slurp` call that returns the whole input text. It reads all the lines and creates a single string variable out of it. The `.=lc` method, called on the `$text` variable, makes the string lowercase and also assigns it back to the variable.

With a substitution `s/\W+/ /`, all non-alphanumeric sequences are replaced with a space. Thus, we eliminate all the punctuation, for example.

The last step of preparatory work is to save the length of the text in a variable so that we use it later in the program directly, instead of calling the `chars` method (see Task 3, String length).

Now, the main loop starts. Its goal is to take all the five-word sequences that occur at least twice in the text and place them in the `%phrases` hash. Each time another copy of the phrase is found, the value in the `%phrases` hash is incremented. At the end of the loop, the hash contains the number of occurrences for each such five-word sequence.

Look at the regex that finds the repetitions:

```raku-static
m:c($start)/(<< [\w+] ** 5 %% \s >>) .+ $0/
```

The main part of it, `<< [\w+] ** 5 %% \s >>`, finds five words separated by a space. The `<<` and `>>` anchors stick to word boundaries, `[\w+ ** 5]` is a sequence of five words, and the separator is mentioned in the `%%` clause: `%% \s`. The regex then needs a copy of the just matched phrase, and this is the job of the `$0` variable inside the regex.

Finally, the `:c` adverb with a parameter—the `$start` value—makes the regex match against the string starting the `$start` position. This counter is incremented in the loop body based on the location of the first found phrase:

```raku-static
$start = $0.from + 1.
```

The rest of the program prints the result as a table. It sorts the found phrases and displays the most frequent first.

{% include nav.html %}
