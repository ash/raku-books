---
title: 39. Unicode digits
---

{% include menu.html %}

*Print all Unicode digits.*

Raku has the best support of Unicode among the modern programming languages. When talking about digits, it is worth remembering that the Unicode standard marks as digits much more than the regular ten characters used in English, for example.

Let us iterate over the whole range of codepoints and select the digits using the `<:digit>` character class in the regex.

```raku
for 1 .. 0x10FFFD {
    my $char = $_.chr;
    print $char if $char ~~ /<:digit>/;
}
```

The program prints 580 characters. Let us list some of them:

०१२३४५६७८९!"# 0123456789٣٢١٠٩٨٧٦٥٤٣٢١٠۴۵۶٩٨٧ $%&'()*੦੧੨੩੪੫੬੭੮੯૦૧૨૩૪૫૬૭૮૯୦୧୨୩୪୫୬୭୮୯௦௧௨௩௪௫௬௭௮ ௯౦౧౨౩౪౫౬౭౮౯೦೧೨೩೪೫೬೭೮೯൦൧൨൩൪൫൬൭൮൯๐๑๒๓๔๕๖๗๘๙໐ ໑໒໓໔໕໖໗໘໙༠༡༢༣༤༥༦༧༨༩၀၁၂၃၄၅၆၇၈၉០១២៣៤៥៦៧៨៩᠐᠑᠒᠓᠔᠕᠖᠗᠘᠙᧐᧑᧒᧓᧔᧕᧖᧗᧘᧙

NOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~•

If you want to know the name of the Unicode digit, call the `uniname` method on the character:

```raku-static
say $char ~ ' ' ~ $char.uniname if $char ~~ /<:digit>/;
```

For example, Arabic digits 0 to 9 have simple names such as `DIGIT ZERO`; another set of Arabic digits ٠, ١, ٢, etc., up to ٩ has names such as `ARABIC-`

```
INDIC DIGIT THREE.
```

{% include nav.html %}
