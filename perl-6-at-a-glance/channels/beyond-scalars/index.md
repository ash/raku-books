---
title: Beyond scalars
---

{% include menu.html %}

Channels may also transfer both arrays and hashes and do it as easily as they work with scalars. Unlike Perl 5, an array will not be unfolded to a list of scalars but will be passed as a single unit. Thus, you may write the following code.

```raku-async
my $c = Channel.new;
my @a = (2, 4, 6, 8);
$c.send(@a);

say $c.receive; # [2 4 6 8]
```

The `@a` array is sent to the channel as a whole and later is consumed as a whole with a single `receive` call.

What’s more, if you save the received value into a scalar variable, that variable will contain an array.

```raku-static
my $x = $c.receive;
say $x.WHAT; # (Array)
```

The same discussions apply to hashes.

```raku-async
my $c = Channel.new;
my %h = (alpha => 1, beta => 2);
$c.send(%h);

say $c.receive; # {alpha => 1, beta => 2}
```

Instead of calling the `list` method, you can use the channel in the list context (but do not forget to close it first).

```raku-static
$c.close;
my @v = @$c;
say @v; # [{alpha => 1, beta => 2}]
```

Note that if you send a list, you will receive it as a list element of the `@v` array.

Here is another example of “dereferencing” a channel:

```raku-static
$c.close;
for @$c -> $x {
    say $x;
} # {alpha => 1, beta => 2}
```

{% include nav.html %}
