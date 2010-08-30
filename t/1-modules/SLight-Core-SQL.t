#!/usr/bin/perl
################################################################################
# 
# SLight - Lightweight Content Manager System.
#
# Copyright (C) 2010 Bartłomiej /Natanael/ Syguła
#
# This is free software.
# It is licensed, and can be distributed under the same terms as Perl itself.
#
# More information on: http://slight-cms.org/
# 
################################################################################
use strict; use warnings; # {{{
use FindBin qw{ $Bin };
use lib $Bin .'/../../lib/';
use utf8;

use English qw{ -no_match_vars };
use Test::More;
# }}}

use SLight::Core::SQL qw(
    sql_connect

    sql_build_query

    sql_query

    sql_select
    sql_insert
    sql_update
    sql_delete
);

plan tests =>
    + 1 # sql_connect

    + 5 # sql_build_query

    + 4 # sql_query

    + 1 # sql_insert
    + 1 # sql_update
    + 1 # sql_delete
    + 1 # sql_select
;

my $test_db = q{/tmp/test.} . $PID .q{.sqlite};
if (-f $test_db) { unlink $test_db; }
my $dbh = sql_connect(
    dbi => 'SQLite:dbname=' . $test_db,
    user => q{},
    pass => q{},
);
isa_ok($dbh, 'DBI::db', 'sql_connect');


is_deeply(
    sql_build_query(
        'dbh'      => $dbh,
        'type'     => 'select',
        'table'    => 'Foo',
        'columns'  => [qw{ col1 col2 }],
        'group_by' => [qw{ col3 }],
    ),
    [ "SELECT `col1`, `col2` FROM Foo GROUP BY col3" ],
    'sql_build_query - select (without where)'
);
is_deeply(
    sql_build_query(
        'dbh'      => $dbh,
        'type'     => 'select',
        'table'    => 'Foo',
        'columns'  => [qw{ col1 col2 }],
        'where'    => [ "col1 = ", 42 ],
        'group_by' => [qw{ col3 col4 }],
        'order_by' => [ 'col2 DESC', 'col1' ],
    ),
    [ "SELECT `col1`, `col2` FROM Foo WHERE col1 = ", 42, " GROUP BY col3, col4 ORDER BY col2 DESC, col1" ],
    'sql_build_query - select (with where)'
);
is_deeply(
    sql_build_query(
        'dbh'      => $dbh,
        'type'     => 'select',
        'table'    => [ 'Foo', 'LEFT JOIN', 'Bar', 'ON', 'Foo.id=Bar.Foo_id' ],
        'columns'  => [qw{ col1 Bar.col2 }],
        'where'    => [ "col1 = ", 42 ],
    ),
    [ "SELECT `col1`, `Bar.col2` FROM Foo LEFT JOIN Bar ON Foo.id=Bar.Foo_id WHERE col1 = ", 42 ],
    'sql_build_query - select (with join)'
);
is_deeply(
    sql_build_query(
        'dbh'      => $dbh,
        'type'     => 'insert',
        'values'   => {
            foo => 1,
            bar => 'bzz bzz bzz'
        },
        'table'    => 'Foo',
    ),
    [ "INSERT INTO Foo (`bar`, `foo`) VALUES ", ['bzz bzz bzz', 1] ],
    'sql_build_query - insert'
);
is_deeply(
    sql_build_query(
        'dbh'      => $dbh,
        'type'     => 'update',
        'set'      => {
            'bar' => 'baz',
            'one' => 'two' 
        },
        'table'    => 'Foo',
        'where'    => [ 'gun =', 'big' ],
    ),
    [ "UPDATE Foo SET `bar`=", "baz", ", `one`=", "two", " WHERE gun =", "big" ],
    'sql_build_query - update'
);
is_deeply(
    sql_build_query(
        'dbh'      => $dbh,
        'type'     => 'delete',
        'table'    => 'Foo',
        'where'    => [ 'gun =', 'big' ],
    ),
    [ "DELETE FROM Foo WHERE gun =", "big" ],
    'sql_build_query - delete'
);

my $sth;

$sth = sql_query(
    dbh   => $dbh,
    query => "CREATE TABLE Foo ( bar INTEGER, baz VARCHAR(128) )",
);
is_deeply(
    $sth->fetchall_arrayref({}),
    [],
    'sql_query - CREATE TABLE'
);

$sth = sql_query(
    dbh   => $dbh,
    query => [ "INSERT INTO Foo (bar, baz) VALUES ", [1, 'bar' ] ]
);
is_deeply(
    $sth->fetchall_arrayref({}),
    [],
    'sql_query - INSERT'
);

$sth = sql_query(
    dbh   => $dbh,
    query => "SELECT bar, baz FROM Foo",
);
is_deeply(
    $sth->fetchall_arrayref({}),
    [
        { bar=>1, baz=>'bar' },
    ],
    'sql_query - SELECT'
);

$sth = sql_insert(
    'dbh'    => $dbh,
    'into'   => 'Foo',
    'values' => {
        bar => 2,
        baz => 'Two',
    }
);
is_deeply(
    $sth->fetchall_arrayref({}),
    [],
    'sql_insert'
);

$sth = sql_update(
    'dbh'   => $dbh,
    'table' => 'Foo',
    'where' => [ 'bar = ', 2 ],
    'set'   => {
        bar => 3,
        baz => 'Two, now three',
    }
);
is_deeply(
    $sth->fetchall_arrayref({}),
    [],
    'sql_update'
);

$sth = sql_delete(
    'dbh'   => $dbh,
    'from'  => 'Foo',
    'where' => [ 'bar = ', 1 ],
);
is_deeply(
    $sth->fetchall_arrayref({}),
    [],
    'sql_delete'
);

$sth = sql_select(
    'dbh'      => $dbh,
    'columns'  => [qw{ bar baz }],
    'from'     => 'Foo',
    'where'    => [ 'bar =', 3 ],
    'group_by' => [ 'bar' ],
    'order_by' => [ 'bar' ],
    'debug'    => 1, # Due to this, a message on STDERR will appear. Harmless, ignore.
);
my $result = $sth->fetchall_arrayref({});
is_deeply(
    $result,
    [
        {
            'bar' => 3,
            'baz' => 'Two, now three',
        }
    ],
    'sql_select'
);

# vim: fdm=marker
