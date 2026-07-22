---
title: 75. Currency converter
---

{% include menu.html %}

*Parse the string with a currency converting request such as ‘10 EUR in USD’ and print the result.*

The task of understanding free text is quite complicated. For the currency conversion, we can create a simple regex that matches the most common quires.

Let’s ignore the way the exchange rate data are obtained and use the hardcoded values:

```raku-static
my %EUR =
    AUD => 1.4994,  CAD => 1.4741,
    CHF => 1.1504,  CNY => 7.7846,
    DKK => 7.4439,  GBP => 0.89148,
    ILS => 4.1274,  JPY => 131.94,
    RUB => 67.471,  USD => 1.1759;
```

This hash contains the exchange rates of a few currencies to Euro. Thus, it is possible to directly use it to get the results for any pair with EUR, such as:

```
10 EUR in GBP
20 ILS to EUR
```

For other combinations, a cross-rate can be used. For example, the request to convert JPY to CHF uses the values of JPY-to-EUR and EUR-to-CHF conversion.

Here is a regex that parses the textual request:

```raku-static
$request ~~
    /(<[\d .]>+) \s* (<:alpha> ** 3) .* (<:alpha> ** 3)/;
```

Let’s also make a loop to accept multiple requests from the keyboard.

Here is the program:

```raku-static
while (my $request = prompt('> ')) {
    $request ~~
        /(<[\d .]>+) \s* (<:alpha> ** 3) .* (<:alpha> ** 3)/;
    my ($amount, $from, $to) = $0, $1, $2;

    my $result = 0;
    if $to eq 'EUR' {
       $result = $amount / %EUR{$from};
    }
    elsif $from eq 'EUR' {
       $result = $amount * %EUR{$to};
    }
    else {
       $result = $amount * %EUR{$to} / %EUR{$from};
    }

    say "$amount $from = $result $to";
}
```

After the regex match, the values are copied to the three variables: `$amount`, `$from`, and `$to`. The `if`—`elsif`—`else` chain is used to choose how the new amount is calculated: either as direct or cross rate.

Run the program and enter different requests with both integer and floatingpoint values for different combinations of the currency codes listed in the `%EUR` hash.

Here are a few ideas of how to improve the program:

1. Check if the entered currency code exists. 2. Make the request case-insensitive. 3. Create another hash with exchange rates against USD and choose it, whenever possible, to avoid cross-calculations.

{% include nav.html %}
