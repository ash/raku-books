---
title: 69. Count hash values
---

{% include menu.html %}

*Having a hash, count the number of occurrences of each of its values.*

For example, a hash is a collection mapping a car’s license plate to the colour of the car or a passport number to the name of the street where the person lives. In the first example, the task is to count how many cars of each colour there are. In the second example, we have to say how many people live on each street. But let’s simply count the colours of fruit :-)

```raku-static
my %data =
    apple => 'red',     avocado => 'green',
    banana => 'yellow', grapefruit => 'orange',
    grapes => 'green',  kiwi => 'green',
    lemon => 'yellow',  orange => 'orange',
    pear => 'green',    plum => 'purple',
;
```

By the way, notice that Raku is tolerant of the comma after the last value in the hash initializer list.

Now it is time to count the statistics that we need.

```raku-static
my %stat;
%stat{$_}++ for %data.values;
say %stat;
```

The `values` method returns a list of all the values that the hash contains. In the loop, they increment the values of the `%stat` hash. A new key is added to `%stat` as soon as a new value from `%data` is seen. An increment of the newly-created element sets the corresponding value to 1. Print the `%stat` hash and see the result. Notice that the output data is not ordered.

```
{green => 4, orange => 2, purple => 1, red => 1, yellow => 2}
```

{% include nav.html %}
