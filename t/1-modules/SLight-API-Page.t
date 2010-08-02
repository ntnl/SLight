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
    + 6 # add_page
    + 1 # update_page
    + 1 # update_pages
    + 2 # delete_page (1x delete + 1x check)
    + 2 # delete_pages (1x delete + 1x check)
    + 2 # get_page
    + 2 # get_pages
    + 1 # get_page_ids_where
    + 1 # get_page_fields_where
# M2:   + 1 # attach_page_to_page
# M2:   + 1 # attach_pages_to_page
;

SLight::Test::Site::prepare_empty(
    test_dir => $Bin .q{/../},
);

use SLight::API::Page;


my $page_0_id = SLight::API::Page::add_page(
    parent_id => undef,
    path      => 'Foo',
);
is ($page_0_id, 1, "add_page (root)");

my $page_1_id = SLight::API::Page::add_page(
    parent_id => $page_0_id,
    path      => 'Foo',
);
is ($page_1_id, 2, "add_page (1/5)");

my $page_2_id = SLight::API::Page::add_page(
    parent_id => $page_1_id,
    path      => 'Bar',
);
is ($page_2_id, 3, "add_page (2/5)");

my $page_3_id = SLight::API::Page::add_page(
    parent_id => $page_0_id,
    path      => 'Baz',
    template  => 'Light',
);
is ($page_3_id, 4, "add_page (3/5)");

my $page_4_id = SLight::API::Page::add_page(
    parent_id => $page_3_id,
    path      => 'Goo',
    template  => 'Haevy',
);
is ($page_4_id, 5, "add_page (4/5)");

my $page_5_id = SLight::API::Page::add_page(
    parent_id => $page_3_id,
    path      => 'Bzz',
);
is ($page_5_id, 6, "add_page (5/5)");



is_deeply(
    SLight::API::Page::get_page($page_1_id),
    {
        id        => $page_1_id,
        parent_id => $page_0_id,
        path      => 'Foo',
        template  => undef,
    },
    'get_page (1 after add)'
);
is_deeply(
    SLight::API::Page::get_page($page_4_id),
    {
        id        => $page_4_id,
        parent_id => $page_3_id,
        path      => 'Goo',
        template  => 'Haevy'
    },
    'get_page (4 after add)'
);



is(
    SLight::API::Page::update_page(
        id => $page_1_id,

        parent_id => $page_4_id,
        path      => 'Faz',
        template  => 'Nested',
    ),
    undef,
    'update_page()'
);

is_deeply(
    SLight::API::Page::get_pages( [$page_1_id, $page_4_id] ),
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
    'get_pages (1 and 4 after update)'
);

is(
    SLight::API::Page::update_pages(
        ids => [ $page_4_id, $page_5_id ],

        template => 'Altered',
    ),
    undef,
    'update_pages()'
);
is_deeply(
    SLight::API::Page::get_pages( [$page_4_id, $page_5_id] ),
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
    'get_pages (4 and 5 after updates)'
);

is_deeply(
    SLight::API::Page::get_page_ids_where(
        template => 'Altered',
    ),
    [
        $page_4_id,
        $page_5_id,
    ],
    "get_page_ids_where() using template"
);

is_deeply(
    [
        sort {$a->{'id'} <=> $b->{'id'}} @{
            SLight::API::Page::get_page_fields_where(
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
    "get_page_fields_where() using template"
);

is (
    SLight::API::Page::delete_page($page_1_id),
    2,
    "delete_page()"
);

is_deeply(
    [ sort {$a->{'id'} <=> $b->{'id'}} @{ SLight::API::Page::get_pages([ $page_1_id, $page_2_id, $page_3_id, $page_4_id, $page_5_id ]) } ],
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
    'delete_page() check with get_pages'
);

is (
    SLight::API::Page::delete_pages([ $page_4_id, $page_5_id ]),
    2,
    "delete_pages()"
);

is_deeply(
    [ sort {$a->{'id'} <=> $b->{'id'}} @{ SLight::API::Page::get_pages([ $page_1_id, $page_2_id, $page_3_id, $page_4_id, $page_5_id ]) } ],
    [
        {
            id        => $page_3_id,
            parent_id => $page_0_id,
            path      => 'Baz',
            template  => 'Light',
        },
    ],
    'delete_pages() check with get_pages'
);

# vim: fdm=marker
