---
title: 77. Remove duplicated words
---

{% include menu.html %}

*Remove repeated words from from a sentence.*

Repeated words are most often unintended typing mistakes. In rare cases, though, this is correct like with the word that:

*He said that that tree is bigger.*

Anyway, let us remove the double words ignoring the grammar for now. To find if the word is repeated, a regex with variables can be used. Then, using a substitution, only one copy of a word is passed to the resulting string.

```raku
my $string = 'This is is a string';
$string ~~ s:g/ << (\w+) >> ' ' << $0 >> /$0/;

say $string;
```

The regex part of the `s` routine is a regex that is first looking for a word (as a sequence of word characters `\w+`) and its copy after a space. The first occurrence is saved in the `$0` variable, which is immediately used in the same regex. It is also used in the replacement part.

To prevent repetitions, the word-edge anchors are used: `<<` for the beginning of a word and `>>` for its end. In the given example, this prevents treating the last two letters of the word This as a separate word, is, and thus, the correct phrase This is a string will not be broken after the substitution.

Notice that non-literal spaces in a regex are not taking part in string matching, although, they are necessary in a sequence `<< (\w+) >>`. The construction `<<(\w+)>>` is a syntax error as it is similar to the character class `<[...]>` or a reference to a named regex like `<:alnum>`, and the compiler prefers explicit spaces in this case.

{% include nav.html %}
