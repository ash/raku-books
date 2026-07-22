---
title: Test runner
---

{% include menu.html %}

Let us start with a simple program that creates a variable and assigns a numeric value to it. We have at least two ways to do that:

```raku-static
my a;
a = 10;
my b = 20;
```

This program does not print anything, so let us add a couple of `say` calls.

```raku-static
my a;
a = 10;
say a;

my b = 20;
say b;
```

Save the test in a file, for example, `variable-declaration.t`, in a dedicated directory `t` and run it. It will generate the result mixed with some test output (e.g., a full AST and a dump of the `%!var` hash) that we added to the compiler earlier. As we are still going to work on the compiler, let us keep the helper output but filter it out to `/dev/null`. The good thing is that Rakudo’s `dd` routine prints its output to `STDERR`, not to `STDOUT`.

```
$ ./lingua t/variable-declaration.t 2>/dev/null
OK
10
20
```

This looks clean, and we even can omit the OK line by using the `note` function instead of a conventional `say`:

```raku-static
if $ast {
    note 'OK';
    $evaluator.eval($ast.made);
}
```

Now, all the helper output goes to `STDERR`, and the program payload is printed via `STDOUT`.

```
$ ./lingua t/variable-declaration.t 2>/dev/null
10
20
```

This output is what we have to compare with the correct result. The simplest way is to save it in another file and just compare the files. The other option is to type the answers in the test program itself in the comments. To allow other comments, which are real comments explaining the program, let us start our special type of comments with a double hash sign:

```raku-static
my a;
a = 10;
say a; ## 10

my b = 20;
say b; ## 20
```

The task is now trivial. We need to create a script that run all the files in the `t` directory, extracts the comments from them, and compares the expected data with the real output. To simplify the task even more, let us assume that the test files are small programs, so if something goes wrong, you can easily spot the line where the error happened.

Let us create another executable program, `run-tests`. It scans the `t` directory and runs the tests one by one.

```raku-static
#!/usr/bin/env raku

my @errors;

test-file($_) for dir('t').sort;

say '-' x 9, ' Summary ', '-' x 9;
if @errors {
    my $n = @errors.elems;
    my $s = $n > 1 ?? 's' !! '';
    say "$n test file$s failed:";
    say "\t$_" for @errors;
}
else {
    say "All tests successfully ran.";
}
```

If there were tests with errors, their list will be printed at the end of the output.

Running a single test is quite straightforward. The following function does the job using the built-in run function, that places the output from `STDOUT` and `STDERR` to the `out` and `err` attributes.

```raku-static
sub test-file($file) {
    my $path = $file.path;
    print "$path... ";
    
    my $proc = run('./lingua', $path, :out, :err);
    my $out = $proc.out.slurp;
    my $err = $proc.err.slurp;

    my $ok = 1;
    if $err ~~ /^Error/ {
        $ok = 0;
    }
    else {
        my $expected = expected($path);
        if $expected ne $out {
            say "\nGOT: $out";
            say "EXPECTED: $expected";
            $ok = 0;
        }
    }

    if $ok {
        say "\e[32mOK\e[39m";
    }
    else {
        say "\e[31mFAIL\e[39m";
        $err ~~ s:g/^^/# /;
        say $err;
        push @errors, $path;
    }
}
```

Escape sequences in the output add colours so that you can immediately see red `FAIL`s or green `OK`s.

There are two possibilities to fail a test: either the file was not parsed, or it generated the output, which differs from expectations. The expected output string is computed from the `##` comments:

```raku-local
sub expected($path) {
    my $expected;
    for $path.IO.lines -> $line {
        $line ~~ /'##'\s*(\N*)/;
        next unless $0;
        $expected ~= "$0\n";
    }

    return $expected;
}
```

Run the program and you should see the following output:

```
$ ./run-tests 
t/variable-declaration.t... OK
--------- Summary ---------
All tests successfully ran.
```

Now we can add more tests to cover more features of Lingua.

{% include nav.html %}
