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

use English qw( -no_match_vars );
use Test::More;
# }}}

plan tests =>
    + 3 # new() works
;

my $site_root = SLight::Test::Site::prepare_empty(
    test_dir => $Bin . q{/../},
);

# Foo (id, name)
#   Bar (id, name, Foo_id)
#     Bar_Data (id, Bar_id, field, type, value)
#     Baz (id, name, Bar_id)

SLight::Core::DB::check();
SLight::Core::DB::run_query(
    query => q{CREATE TABLE Foo ( id PRIMARY KEY, name VARCHAR(128) )},
);
SLight::Core::DB::run_query(
    query => q{CREATE TABLE Bar ( id PRIMARY KEY, name VARCHAR(128), Foo_id INTEGER )},
);
SLight::Core::DB::run_query(
    query => q{CREATE TABLE Bar_Data ( id PRIMARY KEY, name VARCHAR(128), Bar_id INTEGER, field VARCHAR(64), value VARCHAR(64), type VARCHAR(64) )},
);
SLight::Core::DB::run_query(
    query => q{CREATE TABLE Baz ( id PRIMARY KEY, name VARCHAR(128), Bar_id INTEGER )},
);

my $Foo = SLight::Core::Accessor->new(
    table => 'Foo',
    columns => [qw(id, name)],
);
isa_ok($Foo, qw{SLight::Core::Accessor});
my $Bar = SLight::Core::Accessor->new(
    table => 'Bar',
    columns => [qw(id, name, Foo_id)],
);
isa_ok($Bar, qw{SLight::Core::Accessor});
my $Baz = SLight::Core::Accessor->new(
    table => 'Baz',
    columns => [qw(id, name, Bar_id)],
);
isa_ok($Baz, qw{SLight::Core::Accessor});

# vim: fdm=marker
