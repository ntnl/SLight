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
use strict; use warnings; use utf8; # {{{
use FindBin qw{ $Bin };
use lib $Bin .'/../../lib/';

use English qw{ -no_match_vars };
use Test::More;
# }}}

use SLight::Core::SQLite;

plan tests =>
    + 1 # new

    + 3 # run_query

    + 1 # run_insert
    + 1 # run_update
    + 1 # run_delete
    + 1 # run_select

    + 1 # UTF-8 support check
;

my $test_db = q{/tmp/test.} . $PID .q{.sqlite};
if (-f $test_db) { unlink $test_db; }

my $sqlite = SLight::Core::SQLite->new(
    db   => $test_db,
);
isa_ok($sqlite, 'SLight::Core::SQLite', 'new');

my $sth;

$sth = $sqlite->run_query(
    query => "CREATE TABLE Foo ( bar INTEGER, baz VARCHAR(128) )",
);
is_deeply(
    $sth->fetchall_arrayref({}),
    [],
    'sql_query - CREATE TABLE'
);

$sth = $sqlite->run_query(
    query => [ "INSERT INTO Foo (bar, baz) VALUES ", [1, 'bar' ] ]
);
is_deeply(
    $sth->fetchall_arrayref({}),
    [],
    'sql_query - INSERT'
);

$sth = $sqlite->run_query(
    query => "SELECT bar, baz FROM Foo",
);
is_deeply(
    $sth->fetchall_arrayref({}),
    [
        { bar=>1, baz=>'bar' },
    ],
    'sql_query - SELECT'
);

$sth = $sqlite->run_insert(
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

$sth = $sqlite->run_update(
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

$sth = $sqlite->run_delete(
    'from'  => 'Foo',
    'where' => [ 'bar = ', 1 ],
);
is_deeply(
    $sth->fetchall_arrayref({}),
    [],
    'sql_delete'
);

$sth = $sqlite->run_select(
    'columns'  => [qw{ bar baz }],
    'from'     => 'Foo',
    'where'    => [ 'bar =', 3 ],
    'group_by' => [ 'bar' ],
    'order_by' => [ 'bar' ],
    'debug'    => 1,
);
is_deeply(
    $sth->fetchall_arrayref({}),
    [
        {
            'bar' => 3,
            'baz' => 'Two, now three',
        }
    ],
    'sql_select'
);

# Check if UTF is supported properly.
$sth = $sqlite->run_insert(
    'into'   => 'Foo',
    'values' => {
        bar => 8,
        baz => 'zażółć gęślą jaźń',
    }
);
$sth = $sqlite->run_query( query=>'SELECT baz FROM Foo WHERE bar = 8' );

my ($string) = $sth->fetchrow_array();
is( $string, 'zażółć gęślą jaźń', 'utf-8 support');

# vim: fdm=marker
