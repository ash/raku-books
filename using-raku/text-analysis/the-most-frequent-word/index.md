---
title: 13. The most frequent word
---

{% include menu.html %}

*Find the most frequent word in the given text.*

To find the most frequent word, you need first to find all the words in the text.

This can be done via the global regex `m:g/(\w+)/` or by using the `comb` method. The method returns a list of all the matched substrings. In the following example of solving the task, the regex matching is placed inside the `for` loop, which immediately updates the `%count` hash, which keeps the number of occurrences of each found word. To allow counting words caseinsensitively, the `$text` value is first lower-cased with the help of the `lc` string method.

```raku-static
my $text = prompt('Text> ');
my %count;
%count{$_}++ for $text.lc.comb(/\w+/);
say (sort {%count{$^b} <=> %count{$^a}}, %count.keys)[0];
```

The `sort` function sorts the hash using the word frequency as the sorting parameter. Then, the first element, `[0]`, is taken and printed.

Test the program on different texts to see how it works. What you may notice is that the program always prints only one word, even if there are other words with the same number of occurrences. To solve the problem, extract the number of repetitions and filter the `%count` hash to find all the words that match this condition.

```raku-static
my $max = %count{(sort {%count{$^b} <=> %count{$^a}},
                 count.keys)[0]};
.say for %count.keys.grep({%count{$_} == $max});
```

This program prints all the words having the maximum values in `%count`.

{% include nav.html %}
