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

use SLight::Test::Site;

use English qw( -no_match_vars );
use Test::More;
# }}}

plan tests =>
    + 6 # add_Page
    + 1 # update_Page
    + 1 # update_Pages
    + 2 # delete_Page (1x delete + 1x check)
    + 2 # delete_Pages (1x delete + 1x check)
    + 2 # get_Page
    + 2 # get_Pages
    + 2 # get_Page_ids_where
    + 1 # get_Page_fields_where
    + 4 # get_Page_full_path
;

SLight::Test::Site::prepare_empty(
    test_dir => $Bin .q{/../},
);

use SLight::API::Page qw(
    add_Page
    update_Page
    update_Pages
    delete_Page
    delete_Pages
    get_Page
    get_Pages
    get_Page_ids_where
    get_Page_fields_where
    get_Page_full_path
);


my $page_0_id = add_Page(
    parent_id => undef,
    path      => 'Foo',
);
is ($page_0_id, 1, "add_Page (root)");

my $page_1_id = add_Page(
    parent_id => $page_0_id,
    path      => 'Foo',
);
is ($page_1_id, 2, "add_Page (1/5)");

my $page_2_id = add_Page(
    parent_id => $page_1_id,
    path      => 'Bar',
);
is ($page_2_id, 3, "add_Page (2/5)");

my $page_3_id = add_Page(
    parent_id => $page_0_id,
    path      => 'Baz',
    template  => 'Light',
);
is ($page_3_id, 4, "add_Page (3/5)");

my $page_4_id = add_Page(
    parent_id => $page_3_id,
    path      => 'Goo',
    template  => 'Haevy',
);
is ($page_4_id, 5, "add_Page (4/5)");

my $page_5_id = add_Page(
    parent_id => $page_3_id,
    path      => 'Bzz',
);
is ($page_5_id, 6, "add_Page (5/5)");



is_deeply(
    get_Page_full_path(12345),
    [],
    'get_Page_full_path (1/4) non-existing page ID does not kill the function'
);
is_deeply(
    get_Page_full_path($page_0_id),
    [],
    'get_Page_full_path (2/4) root path = empty list'
);
is_deeply(
    get_Page_full_path($page_1_id),
    [ 'Foo' ],
    'get_Page_full_path (3/4) first level depth = one element list'
);
is_deeply(
    get_Page_full_path($page_4_id),
    [qw( Baz Goo )],
    'get_Page_full_path (4/4) second level depth = two elements list'
);



is_deeply(
    get_Page($page_1_id),
    {
        id        => $page_1_id,
        parent_id => $page_0_id,
        path      => 'Foo',
        template  => undef,
    },
    'get_Page (1 after add)'
);
is_deeply(
    get_Page($page_4_id),
    {
        id        => $page_4_id,
        parent_id => $page_3_id,
        path      => 'Goo',
        template  => 'Haevy'
    },
    'get_Page (4 after add)'
);



is(
    update_Page(
        id => $page_1_id,

        parent_id => $page_4_id,
        path      => 'Faz',
        template  => 'Nested',
    ),
    undef,
    'update_Page()'
);

is_deeply(
    [
        sort {$a->{'id'} <=> $b->{'id'}} @{
            get_Pages( [$page_1_id, $page_4_id] )
        }
    ],
    [
        {
            id        => $page_1_id,
            parent_id => $page_4_id,
            path      => 'Faz',
            template  => 'Nested',
        },
        {
            id        => $page_4_id,
            parent_id => $page_3_id,
            path      => 'Goo',
            template  => 'Haevy'
        },
    ],
    'get_Pages (1 and 4 after update)'
);

is(
    update_Pages(
        ids => [ $page_4_id, $page_5_id ],

        template => 'Altered',
    ),
    undef,
    'update_Pages()'
);
is_deeply(
    [
        sort {$a->{'id'} <=> $b->{'id'}} @{
            get_Pages( [$page_4_id, $page_5_id] )
        }
    ],
    [
        {
            id        => $page_4_id,
            parent_id => $page_3_id,
            path      => 'Goo',
            template  => 'Altered',
        },
        {
            id        => $page_5_id,
            parent_id => $page_3_id,
            path      => 'Bzz',
            template  => 'Altered'
        },
    ],
    'get_Pages (4 and 5 after updates)'
);

is_deeply(
    get_Page_ids_where(
        path => [qw( Goo Bzz )],
    ),
    [
        $page_4_id,
        $page_5_id,
    ],
    "get_Page_ids_where() using multiple paths"
);

is_deeply(
    get_Page_ids_where(
        template => 'Altered',
    ),
    [
        $page_4_id,
        $page_5_id,
    ],
    "get_Page_ids_where() using template"
);

is_deeply(
    [
        sort {$a->{'id'} <=> $b->{'id'}} @{
            get_Page_fields_where(
                template => 'Altered',

                _fields  => [qw( id path )],
            )
        }
    ],
    [
        {
            id        => $page_4_id,
            path      => 'Goo',
        },
        {
            id        => $page_5_id,
            path      => 'Bzz',
        },
    ],
    "get_Page_fields_where() using template"
);

################################################################################
#                   delete_* functions tests
################################################################################

is (
    delete_Page($page_1_id),
    2,
    "delete_Page()"
);

is_deeply(
    [ sort {$a->{'id'} <=> $b->{'id'}} @{ get_Pages([ $page_1_id, $page_2_id, $page_3_id, $page_4_id, $page_5_id ]) } ],
    [
        {
            id        => $page_3_id,
            parent_id => $page_0_id,
            path      => 'Baz',
            template  => 'Light',
        },
        {
            id        => $page_4_id,
            parent_id => $page_3_id,
            path      => 'Goo',
            template  => 'Altered',
        },
        {
            id        => $page_5_id,
            parent_id => $page_3_id,
            path      => 'Bzz',
            template  => 'Altered'
        },
    ],
    'delete_Page() check with get_Pages'
);

is (
    delete_Pages([ $page_4_id, $page_5_id ]),
    2,
    "delete_Pages()"
);

is_deeply(
    [ sort {$a->{'id'} <=> $b->{'id'}} @{ get_Pages([ $page_1_id, $page_2_id, $page_3_id, $page_4_id, $page_5_id ]) } ],
    [
        {
            id        => $page_3_id,
            parent_id => $page_0_id,
            path      => 'Baz',
            template  => 'Light',
        },
    ],
    'delete_Pages() check with get_Pages'
);

# vim: fdm=marker
