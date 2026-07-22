---
title: Files
---

{% include menu.html %}

To get the content of a file, use the `slurp` built-in function, which reads the whole file and returns a string.

```raku-static
say slurp "file.txt";

The function that does the opposite is called spurt, it writes the string to a file.

Let us implement the Unix’s cp command in Perl 6.

my ($source, $dest) = @*ARGS;

my $data = slurp $source;
spurt $dest, $data;
```

By default, either a new destination file will be created or rewritten if it already exists. You can open the file in the append mode by adding the `:append` value in the third argument:

```raku-static
spurt $dest, $data, :append;
```

Another mode, :`createonly`, generates an error if the file exists.

```raku-static
spurt $dest, $data, :createonly;
```

Both `slurp` and `spurt` accept an argument with the encoding name:

```raku-local
my ($source, $dest) = @*ARGS;

my $data = slurp $source, enc => 'UTF-8';
spurt $dest, $data, enc => 'UTF-16';
```

The `Str` class inherits (from the `Cool` class) the `IO` method that returns an object of the `IO::Path` class. It contains some useful information about the file.

For example, this is how you can get the absolute path to a local file:

```raku-local
say 'file.txt'.IO.abspath;
```

The `IO.dir` method prints the content of a directory:

```raku-static
say '.'.IO.dir;

The IO.extension method returns an extension of a file:

say $filename.IO.extension;
say $filename.IO.extension;
```

Finally, there are one-letter named methods for making checks of the file’s or directory’s existence or checking its properties:

```raku-local
say 1 if 'file.txt'.IO.e; # same as -e 'file.txt' in Perl 5 (file exists)
say 1 if 'file.txt'.IO.f; # -f (is a file)
say 1 if '..'.IO.d;       # -d (is a directory)
```

{% include nav.html %}
