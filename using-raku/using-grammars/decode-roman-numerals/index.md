---
title: 84. Decode Roman numerals
---

{% include menu.html %}

*Convert a string, with a Roman number, to a decimal number.*

The task is opposite to Task 46, Convert to Roman numerals, but let’s use grammars to solve it. The idea is to directly find the sequences of Roman digits that correspond to thousands, hundreds, tens, and ones. For example, as soon as the program sees LXX, it knows that it is equal to 70. We are not analysing which letters go on the left or right of the given one. Instead, the result is achieved directly.

Here is a complete program, the biggest part of which is the grammar class. It uses a global variable `$n` for accumulating the decimal number during the parsing.

```raku-nobrowser
my $n = 0;
grammar Roman {
    token TOP {
        <thousands>? <hundreds>? <tens>? <ones>?
    }

    token thousands {
        | M    { $n += 1000 }   | MM   { $n += 2000 }
        | MMM  { $n += 3000 }   | MMMM { $n += 4000 }
    }

    token hundreds {
        | C    { $n += 100 }    | CC   { $n += 200 }
        | CCC  { $n += 300 }    | CD   { $n += 400 }
        | D    { $n += 500 }    | DC   { $n += 600 }
        | DCC  { $n += 700 }    | DCCC { $n += 800 }
        | CM   { $n += 900 }
    }
    token tens {
        | X    { $n += 10 }     | XX   { $n += 20 }
        | XXX  { $n += 30 }     | XL   { $n += 40 }
        | L    { $n += 50 }     | LX   { $n += 60 }
        | LXX  { $n += 70 }     | LXXX { $n += 80 }
        | XC   { $n += 90 }
    }

    token ones {
        | I    { $n += 1 }      | II   { $n += 2 }
        | III  { $n += 3 }      | IV   { $n += 4 }
        | V    { $n += 5 }      | VI   { $n += 6 }
        | VII  { $n += 7 }      | VIII { $n += 8 }
        | IX   { $n += 9 }
    }
}

my $roman = 'MMXVIII';
Roman.parse($roman);
say $n; # 2018
```

The `TOP` token of the grammar describes how the Roman number is built. A Roman number is a sequence of thousands, hundreds, tens, and ones. All these parts are optional: `<thousands>? <hundreds>? <tens>? <ones>?`.

Then, the grammar defines the tokens for each individual part. Their structure is similar: It is a set of alternatives; examine, for instance, the `ones` to-

```
ken: I | II | III | IV | V | VI | VII | VIII | IX.
```

Each branch of alternatives is equipped with a simple code block that updates the value of the global variable `$n`. To make the grammar reusable, add the `{ $n = 0 }` block at the beginning of `TOP`. As homework, convert the grammar to use `$/.make` and `$/.made` methods of the match object to collect the parts of the value without using a global variable.

{% include nav.html %}
