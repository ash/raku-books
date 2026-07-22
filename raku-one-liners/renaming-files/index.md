---
title: Renaming files
---

{% include menu.html %}

Let us solve a task to rename all the files passed in the command-line arguments and give the files sequential numbers in the preferred format. Here is an example of the command line:

```
$ raku rename.raku *.jpg img_0000.jpg
```

In this example, all image files in the current directory will be renamed to img_0001.jpg, img_0002.jpg, etc.

And here’s the possible solution in Raku (save it in `rename.raku`):

```raku-local
@*ARGS[0..*-2].sort.map: *.Str.IO.rename(++@*ARGS[*-1])
```

The pre-defined dynamic variable `@*ARGS` contains the arguments from the command line. In the above example, the shell unrolls the `*.jpg` mask to a list of files, so the array contains them all. The last element is the renaming sample img_0000.jpg.

If you are familiar with C or Perl, notice that the variable is called `ARGS`, not

```
ARGV.
```

To loop over all the files (and skipping the last file item with the file mask), we are taking the slice of `@*ARGS`. The `0..*-2` construct creates a range of indices to take all elements except the last one.

Then, the list is sorted (the original `@*ARGS` array stays unchanged), and we iterate over the file names using the `map` method.

The body of `map` contains a `WhateveCode` block (see Chapter 6); it takes the string representation of the current value, makes an `IO::Path` object out of it, and calls the `rename` method. Notice that the `IO` method creates an object of the `IO::Path` class; while a bare `IO` is a role in the hierarchy of the Raku object system.

Finally, the increment operator `++` changes the renaming sample (which is held in the last, `*-1`st, element of `@*ARGS`). When the operator is applied to a string, it increments the numeric part of it, so we get img_0001.jpg, img_0002.jpg, etc.

{% include nav.html %}
