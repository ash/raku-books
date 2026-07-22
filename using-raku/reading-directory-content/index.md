---
title: 97. Reading directory content
---

{% include menu.html %}

*Print the file names from the current directory.*

Reading a directory can be done using the `dir` routine defined in the `IO::Path` class.

```raku-local
say dir();
```

This tiny program does not do the task really satisfactory, as the `dir` routine returns a lazy sequence (an object of the `Seq` data type) of `IO::Path` objects.

To get the textual file names, take the path part of an `IO::Path` object using the `path` method:

```raku-local
.path.say for dir;
```

The code is equivalent to the more verbose fragment:

```raku-local
for dir() -> $file {
    say $file.path;
}
```

If you want to print full paths of the files in a directory, use the `absolute` method:

```raku-local
.absolute.say for dir;
```

The `test` named argument of the `dir` routine allows selecting filenames that match a certain regex, for example, listing all jpeg files:

```raku-local
for dir(test => /\.jpg$/) -> $file {
    say $file.path;
}
```

{% include nav.html %}
