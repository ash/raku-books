---
title: 8. Incrementing filenames
---

{% include menu.html %}

*Generate a list of filenames like file1.txt, file2.txt, etc.*

Raku allows incrementing those kinds of filenames directly:

```raku
my $filename = 'file0.txt';
for 1..5 {
    $filename++;
    say $filename;
}
```

This program prints the list of consequent filenames:

```
file1.txt
file2.txt
file3.txt
file4.txt
file5.txt
```

Notice that after reaching 9, the e letter from file is incremented. Thus, `file9.txt` is followed by `filf0.txt`. To prevent that, add enough zeros in the template:

```raku
my $filename = 'file000.txt';
for 1..500 {
    $filename++;
    say $filename;
}
```

Now, the sequence starts with `file001.txt` and continues to `file500.txt`.

Multiple file extensions in the template, say `file000.tar.gz`, are also handled properly, so the numeric part is incremented.

{% include nav.html %}
