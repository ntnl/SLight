#!/usr/bin/perl
################################################################################
# 
# SLight - Lightweight Content Management System.
#
# Copyright (C) 2010-2011 Bartłomiej /Natanael/ Syguła
#
# This is free software.
# It is licensed, and can be distributed under the same terms as Perl itself.
#
# More information on: http://slight-cms.org/
# 
################################################################################
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .'/../../lib/';

use SLight::Core::DB;
use SLight::Test::Site;

use English qw( -no_match_vars );
use Test::More;
# }}}

use SLight::Core::Accessor;

plan tests =>
    + 3 # new() works

    + 4 # add_ENTITY

    + 3 # get_ENTITY
    + 1 # get_ENTITIES
    + 1 # get_ENTITY_fields
    + 1 # get_ENTITIES_fields
    + 2 # get_ENTITIES_ids_where
    + 1 # get_ENTITIES_fields_where
    
    + 2 # update_ENTITY

    + 1 # delete_ENTITY
;

# Test DB structure:
#
#   Foo (id, name)
#       Bar (id, name, Foo_id)
#           Bar_Data (id, Bar_id, field, type, value)
#           Baz (id, name, Bar_id)

# Prepare test database... {{{
my $site_root = SLight::Test::Site::prepare_empty(
    test_dir => $Bin . q{/../},
);

SLight::Core::DB::check();
SLight::Core::DB::run_query(
    query => q{CREATE TABLE Foo ( id INTEGER PRIMARY KEY, name VARCHAR(128) )},
);
SLight::Core::DB::run_query(
    query => q{CREATE TABLE Bar ( id INTEGER PRIMARY KEY, name VARCHAR(128), Foo_id INTEGER, metadata TEXT )},
);
SLight::Core::DB::run_query(
    query => q{CREATE TABLE Bar_Data ( id INTEGER PRIMARY KEY, Bar_id INTEGER, field VARCHAR(64), value VARCHAR(64), type VARCHAR(64) )},
);
SLight::Core::DB::run_query(
    query => q{CREATE TABLE Baz ( id INTEGER PRIMARY KEY, name VARCHAR(128), Bar_id INTEGER )},
);
# }}}

note(q{}); #####################################################################
note(q{Defining relations});
note(q{}); #####################################################################

my $Foo = SLight::Core::Accessor->new(
    table   => 'Foo',
    columns => [qw( id name )],
);
isa_ok($Foo, qw{SLight::Core::Accessor});

my $Bar = SLight::Core::Accessor->new(
    table   => 'Bar',
    columns => [qw( id name )],

    refers => {
        F => {
            table   => 'Foo',
            columns => [qw( id name )],
        },
    },
    referenced => {
        Data => {
            table   => 'Bar_Data',
            key     => 'field',
            columns => [qw( value type )],
        },
    },

    has_metadata => 1,
);
isa_ok($Bar, qw{SLight::Core::Accessor});

my $Baz = SLight::Core::Accessor->new(
    table => 'Baz',
    columns => [qw(id name Bar_id)],
);
isa_ok($Baz, qw{SLight::Core::Accessor});

note(q{}); #####################################################################
note('Adding stuff into tables');
note(q{}); #####################################################################

is(
    $Foo->add_ENTITY(
        id   => 1,
        name => 'First Foo'
    ),
    1,
    q{add_Entity into Foo}
);
is(
    $Foo->add_ENTITY(
        name => 'Second Fu'
    ),
    2,
    q{add_Entity into Foo (2)}
);

is(
    $Bar->add_ENTITY(
        id   => 1,
        name => 'First Bar',

        Foo_id => 1,
    ),
    1,
    q{add_Entity into Bar}
);
is(
    $Bar->add_ENTITY(
        name => 'Bar two',

        Foo_id => 2,

        'Data.value' => {
            'alpha' => "First",
            'beta'  => "2",
            'gamma' => undef,
        },
        'Data.type' => {
            'alpha' => "String",
            'beta'  => "Integer",
            'gamma' => "Empty",
        },

        metadata => {
            entity => 'Second',
        },
    ),
    2,
    q{add_Entity into Bar (2)}
);

note(q{}); #####################################################################
note('Getting stuff out');
note(q{}); #####################################################################

is_deeply(
    $Foo->get_ENTITY( 1 ),
    {
        id   => 1,
        name => 'First Foo'
    },
    q{get_ENTITY from Foo},
);
is_deeply(
    $Bar->get_ENTITY( 1 ),
    {
        id   => 1,
        name => 'First Bar',

        'F.id'   => 1,
        'F.name' => 'First Foo',

        metadata => undef,
    },
    q{get_ENTITY from Bar},
);
is_deeply(
    $Bar->get_ENTITY( 2 ),
    {
        id   => 2,
        name => 'Bar two',

        'F.id'   => 2,
        'F.name' => 'Second Fu',

        'Data.value' => {
            'alpha' => "First",
            'beta'  => "2",
            'gamma' => undef,
        },
        'Data.type' => {
            'alpha' => "String",
            'beta'  => "Integer",
            'gamma' => "Empty",
        },

        metadata => {
            entity => 'Second',
        },
    },
    q{get_ENTITY from Bar},
);

is_deeply(
    $Foo->get_ENTITIES( [ 1, 2 ] ),
    [
        {
            id   => 1,
            name => 'First Foo'
        },
        {
            id   => 2,
            name => 'Second Fu'
        },
    ],
    q{get_ENTITIES from Foo},
);

# *_fields
is_deeply(
    $Bar->get_ENTITY_fields( 1, [qw( name F.name )] ),
    {
        id => 1,

        name => 'First Bar',

        'F.name' => 'First Foo',
    },
    q{get_ENTITY_fields from Bar (1)},
);
is_deeply(
    $Bar->get_ENTITIES_fields( [ 1, 2, 123 ], [qw( name F.name Data.value )] ),
    [
        {
            id => 1,

            name => 'First Bar',

            'F.name' => 'First Foo',
        },
        {
            id => 2,

            name => 'Bar two',

            'F.name' => 'Second Fu',

            'Data.value' => {
                'alpha' => "First",
                'beta'  => "2",
                'gamma' => undef,
            },
        },
    ],
    q{get_ENTITY_fields from Bar (1 + 2)},
);

# *_where

is_deeply(
    $Bar->get_ENTITIES_ids_where(
        name => [ 'Bar two' ],
    ),
    [ 2, ],
    q{get_ENTITIES_ids_where from Bar},
);
is_deeply(
    $Bar->get_ENTITIES_ids_where(
        'F.id' => [ 1 ],
    ),
    [ 1, ],
    q{get_ENTITIES_ids_where from Bar},
);

# *_fields_where
is_deeply(
    $Bar->get_ENTITIES_fields_where(
        _fields => [qw( name F.name )],

        'F.id' => [ 1, 2 ],
    ),
    [
        {
            id => 1,

            name => 'First Bar',

            'F.name' => 'First Foo',
        },
        {
            id => 2,

            name => 'Bar two',

            'F.name' => 'Second Fu',
        },
    ],
    q{get_ENTITY_fields_where from Bar},
);

note(q{}); #####################################################################
note('Updating stuff');
note(q{}); #####################################################################

$Foo->update_ENTITY(
    id   => 2,
    name => 'Foo number two',
);
is_deeply(
    $Foo->get_ENTITY( 2 ),
    {
        id   => 2,
        name => 'Foo number two',
    },
    q{update_ENTITY from Foo},
);

$Bar->update_ENTITY(
    id   => 2,
    name => 'Bar number two',
    
    'Data.value' => {
        'theta' => '4 - Theta',
    }
);
is_deeply(
    $Bar->get_ENTITY( 2 ),
    {
        id   => 2,
        name => 'Bar number two',

        'F.id'   => 2,
        'F.name' => 'Foo number two',

        'Data.value' => {
            'alpha' => "First",
            'beta'  => "2",
            'theta' => '4 - Theta',
            'gamma' => undef,
        },
        'Data.type' => {
            'alpha' => "String",
            'beta'  => "Integer",
            'gamma' => "Empty",
            'theta' => undef,
        },

        metadata => {
            entity => 'Second',
        },
    },
    q{update_ENTITY from Bar},
);
# Maybe, if I set:
#   'Data.*' => {
#       field => undef,
#   },
# then it will delete the row?

note(q{}); #####################################################################
note('Deleting stuff');
note(q{}); #####################################################################

$Foo->delete_ENTITY( 2 );

is($Foo->get_ENTITY( 2 ), undef, q{delete_ENTITY (worked)});

# vim: fdm=marker
