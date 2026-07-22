---
title: Merging files horizontally
---

{% include menu.html %}

Let us merge a few files into a single file. The task is to take two (or three, or more) files and copy their contents line by line. For example, we want to merge two log files, knowing that all their lines correspond to each other.

File a.txt:

```
2019/12/20 11:16:13
2019/12/20 11:17:58
2019/12/20 11:19:18
2019/12/20 11:24:30
```

File b.txt:

```
"/favicon.ico" failed (No such file)
"/favicon.ico" failed (No such file)
"/robots.txt" failed (No such file)
"/robots.txt" failed (No such file)
```

The first one-liner illustrates the idea:

```raku-local
.say for [Z~] @*ARGS.map: *.IO.lines;
```

It is assumed that the program is run as follows:

```
$ raku merge.raku a.txt b.txt
```

For each filename (`@*.ARGS.map`) in the command line, an `IO::Path` object is created (`.IO`), and the lines from the files are read (`.lines`).

In the case of two files, we have two sequences which are concatenated line by line using the zip meta-operator `Z` applied to the concatenation infix `~`.

After that step, we get another sequence which we can print line by line

```raku-static
(.say for).

2019/12/20 11:16:13"/favicon.ico" failed (No such file)
2019/12/20 11:17:58"/favicon.ico" failed (No such file)
2019/12/20 11:19:18"/robots.txt" failed (No such file)
2019/12/20 11:24:30"/robots.txt" failed (No such file)
```

The result is formally correct, but let’s add a space between the original lines. Here is an updated version of the one-liner:

```raku-local
.trim.say for [Z~] @*ARGS.map: *.IO.lines.map: *~ ' '
```

Here, a space character is appended to the end of each line (`.map: *~ ' '`), and as there will be one extra space at the end of the combined line, it is removed by the `trim` method. Its sibling, `trim-trailing`, could be used instead (or a regex if you care about original trailing spaces happened to be in the second file).

With the above change, the files are perfectly merged now:

```
2019/12/20 11:16:13 "/favicon.ico" failed (No such file)
2019/12/20 11:17:58 "/favicon.ico" failed (No such file)
2019/12/20 11:19:18 "/robots.txt" failed (No such file)
2019/12/20 11:24:30 "/robots.txt" failed (No such file)
```

There’s no problem to merge the same file to itself, or to provide more than two files, for example:

```
$ raku merge.raku a.txt a.txt a.txt
```

{% include nav.html %}
