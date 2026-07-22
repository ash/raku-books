---
title: Optional parameters
---

{% include menu.html %}

Optional parameters are marked with a question mark after their names. The `defined` built-in function helps to tell if the parameter was really passed:

```raku
sub send-mail(Str $to, Str $bcc?) {
    if defined $bcc {
        # . . .
        say "Sent to $to with a bcc to $bcc.";
    }
    else {
        # . . .
        say "Sent to $to.";
    }
}

send-mail('mail@example.com');
send-mail('mail@example.com', 'copy@example.com');
```

{% include nav.html %}
