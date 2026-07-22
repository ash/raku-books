---
title: 9. Random passwords
---

{% include menu.html %}

*Generate a random string that can be used as a password.*

One of the possible solutions looks like this:

```raku
say ('0' .. 'z').pick(15).join('');
```

The `pick` method with no arguments takes a random element from the range of the ASCII characters between `0` and `z`. In the above example, calling `pick(15)` selects 15 different characters, which are then joined together using the `join` method.

It is important to know the two key features of the `pick` method. First, when called with an integer argument bigger than 1, the result contains only unique elements. Thus, all the characters in the password are different.

The second feature is a consequence of the first one. If the provided list of elements is not long enough, and its length is less than the argument of `pick`, the result is as long as the original data list.

To see which elements are used for generating a password, run the code with a number bigger than the whole ASCII sequence:

```raku
say ('0' .. 'z').pick(1000).sort.join('');
```

With this request, you will see all the characters that participate in forming a random password:

```raku-static
0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`
abcdefghijklmnopqrstuvwxyz
```

An example of a generated password: `05<EV]^bdfhnpyz`.

To limit the character range, list the characters you want to see in a password:

```raku
my @chars = '0' ... '9', 'A' ... 'Z', 'a' ... 'z';
say @chars.pick(15).join('');
```

Now the password only contains alphanumeric symbols: `2zOIySp5PHb08Ql`.

The `...` operator creates a sequence. Be warned not to use the `..` operator, which creates a range, in which case the `@chars` array is an array of ranges rather than a flat array of single characters.

The solution is quite elegant and does not require explicit use of the `rand` function. Neither loops are needed.

Now, let us solve the task in such a way that characters may be repeated in the result. It is still possible to use the `pick` method but it should be called independently a few times.

```raku
my $password = '';
$password ~= ('0' .. 'z').pick() for 1..15;
say $password;
```

Now, the password can include the same character more than once, for example: `jn@09Icoys@tD;o`.

To get the string of unique characters, use the `pick` method instead of `roll`. When using roll, you have to make sure the source list of characters is bigger than the length of your password.

```raku
my $password = '';
$password ~= ('0' .. 'z').roll() for 1..15;
say $password;
```

Run the code a few times to confirm that you generate good passwords that are all different and do not contain the same characters more than once.

{% include nav.html %}
