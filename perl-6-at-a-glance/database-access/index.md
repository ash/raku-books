---
title: Database access
---

{% include menu.html %}

Install the DBIish module to get a powerful tool for working with databases*:

```
$ panda install DBIish
```

You also will need the database driver; for example, libmysqlclient for working with MySQL. Check the documentation of the DBIish module on modules.perl6.org if you want to work with a different database engine.

The module provides an interface similar to the DBI’s in Perl 5. You obtain a database handler, `$dbh`, and they work via the statement handler, `$sth`. Let us see some details in the following example.

```raku-static
use DBIish;

# Connecting to a remote database
my $dbh = DBIish.connect(
    'mysql',
    :host<example.com>,
    :port(3306),
    :database<test>,
    :user<test>,
    :password<test_password>
);

# Now, prepare the statement to get all the data from a table
my $sth = $dbh.prepare("select * from calendar");
# And execute the request
$sth.execute;

# Fetch all the rows
my @arr = $sth.allrows;
say @arr;

# Finalise the statement and close the connection
$sth.finish;
$dbh.dispose;
```

There are several ways of fetching data. The one shown in the code is the `$sth.allrows` method that returns a list of lists with the data from the table.

Alternatively, rows can be read one by one using the `$sth.row` method. To get the row data in a hash, add the `:hash` attribute: `$sth.row(:hash)`.

```raku-static

my $sth = $dbh.prepare("select what, when from calendar");
$sth.execute;

my $row_hash = $sth.row(:hash);
say $row_hash;
```

With the `insert` statements, placeholders may be used to avoid the need of escaping the values before injecting them into the SQL query. In the following example, a new row will be written to the database table. The actual values are passed to the `execute` method.

```raku-static
my $sth = $dbh.prepare(
    "insert into calendar values (?, ?)"
);

$sth.execute('2017-01-01', 'Wake up');
```

{% include nav.html %}
