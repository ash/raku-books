---
title: Programming for the Internet
---

{% include menu.html %}

The simplest way to build a web server in Perl 6 is to use a PSGI server called Bailador. This is a module that you can find on the official page with the list of Perl 6 modules: modules.perl6.org. If you are using the Rakudo Star distribution, use the `panda`* command line utility to install the module.

```
$ panda install Bailador
```

Bailador copies the interface of the well-known framework Dancer for Perl 5. The name is the same but in Spanish.

Here is the minimal programme that implements the web server.

```raku-static
use Bailador;

get '/' => sub {
    'Hello, world!'
}

baile;
```

The programme describes the action, which the server does in response to the request to its home page. The `baile` (dance in Spanish) method starts the main loop of the PSGI server.

Run the programme:

```
$ perl6 web1.pl
```

You will get the output informing you that the server is ready to accept requests.

```
Entering the development dance floor: http://0.0.0.0:3000
[2016-12-27T20:27:34Z] Started HTTP server.
```

Open that page in a browser, and you will see the desired output: “Hello, world!”

The next step is to parse the URL and respond accordingly. Bailador allows extract parameters from the URL with the colon syntax:

```raku-static
get '/:name' => sub ($name) {
    "Hello, $name!"
}
```

Please note that you cannot omit the space after the `sub` keyword. There is an alternative. As the sub is anonymous, you may use the pointy block instead:

```raku-static
get '/:name' => -> $name {
    "Hello, $name!"
}
```

Add it to the programme, restart the server, and go to, for example, `http://0.0.0.0:3000/abc`. You should get the “Hello, abc” output in the browser.

Bailador is happy to accept regexes instead of the fixed URLs. For example, let’s create the URL `/square-of/N`, where the `N` can be any non-negative integer.

```raku-static

get / 'square-of/' (<digit>+) / => sub ($n) {
    $n * $n
}
```

The regex pattern `/ 'square-of/' (<digit>+) /` contains the capturing part, and so the variable `$n` will be set to the number from the URL. As Bailador reads the address patterns in the order they appear in the file, make sure to put the method above the handler of `/name`. Now, test how it works at `http://0.0.0.0:3000/square-of/5`; it should print 25.

It is possible to access some environment variables in the URL handler. Use the `request` method and take the `request.env` hash from it, as is demonstrated in the example:

```raku-static
get '/ua' => sub {
    request.env<HTTP_USER_AGENT> ~
    '<br />' ~
    request.env<QUERY_STRING>
}
```

The page `http://0.0.0.0:3000/ua?key=value` will now print the user agent name and list the query parameters of the request.

After we generate the output from the Perl code, let us move to using templates. Bailador will search for the template files in the `views` directory.

Save a simple text template to `views/test.tt`, and use it in the server like this:

```raku-static

use Bailador;

get '/form' => sub {
    template 'test.tt';
}

baile;
```

To print something inside the template, pass the data in hash:

```raku-static

get '/form/:name' => sub ($name) {
    template 'name.tt', {name => $name}
}
```

You can access the data from a template. It receives the argument containing everything that you just passed.

```

```

`% my ($params) = @_;`

`Hi, <%= $params<name> %>!`

{% include nav.html %}
