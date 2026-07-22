---
title: An example
---

{% include menu.html %}

Finally, a funny example of how promises can be used for implementing the sleep sort algorithm. In sleep sort, every integer number, consumed from the input, creates a delay proportional to its value. As the sleep is over, the number is printed out.

Promises are exactly the things that will execute the code and tell the result after they are done. Here, a list of promises is created, and then the programme waits until all of them are done (this time, we do it using the `await` keyword).

```raku-local
my @promises;
for @*ARGS -> $a {
    @promises.push(start {
        sleep $a;
        say $a;
    })
}

await(|@promises);
```

Provide the programme with a list of integers:

```
$ perl6 sleep-sort.pl 3 7 4 9 1 6 2 5
```

```

```

For each value, a separate promise will be created with a respective delay in seconds. You may experiment and make smaller delays such as `sleep $a / 10` instead. The presence of `await` ensures that the programme is not finished until all the promises are kept.

As an exercise, let’s simplify the code and get rid of an explicit array that collects the promises.

```raku-local
await do for @*ARGS {
    start {
        sleep $_;
        say $_;
    }
}
```

First, we use the `$_` variable here and thus don’t have to declare `$a`. Second, notice the `do for` combination, which returns the result of each loop iteration. The following code will help you to understand how that works:

`my @a = do for 1..5 {$_ * 2};`

`say @a; # [2 4 6 8 10]`

{% include nav.html %}
