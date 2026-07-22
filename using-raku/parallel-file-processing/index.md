---
title: 94. Parallel file processing
---

{% include menu.html %}

*Process the files from the current directory in a few parallel threads.*

We have to do something with each file in the directory, and it has to be done in such a way that files are processed independently with a few workers. It is not possible to predict how long the process will take for each individual file, that’s why we need a common queue, which supplies the filenames for the next available worker.

A good candidate for the queue is a channel.

```raku-local
my $channel = Channel.new();
$channel.send($_) for dir();
$channel.close;
```

All the file names are sent to the channel, which we close afterward. (On how to read directories, see more details in Task 97, Reading directory con-

*tents.)*

Channels are designed to work thread-safe. It means that it is possible to get data from the channel using several threads, and each value is processed only once. Raku cannot predict which thread gets which name but it can guarantee that each data item is only read by the threads once.

```raku-static
my @workers;
for 1..4 {
    push @workers, start {
        while (my $file = $channel.poll) {
            do_something($file);
        }
    }
}
```

The code on the previous page creates four independent workers using the `start` keyword. As they are executed independently not only from each other but also from the main program, it is important to wait until all of them are done:

```raku-static
await(@workers);
```

The elements of the `@workers` array are promises (objects of the `Promise` data type). The `await` routine waits until all the promises are kept.

Another practical way of creating and waiting workers is shown in Task 92, Sleep Sort: instead of collecting them in an array, you can use the `gather` and `take` keywords.

Examine the main loop:

```raku-static
while (my $file = $channel.poll) {
    do_something($file);
}
```

On each iteration, a value from the channel is read. The `poll` method ensures that the reading stops after the channel is exhausted.

All four threads are doing similar work and are polling the same channel. This approach distributes the filenames that were sent to the channel between the workers. As a name has been read, it is removed from the channel, and the next read request returns the next name.

Finally, cook the `do_something` sub according to your needs. In the following simplest example, it only prints filenames:

```raku-static
sub do_something($file) {
    say $file.path;
}
```

{% include nav.html %}
