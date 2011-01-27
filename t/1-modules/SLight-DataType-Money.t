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

# Test for Money DataType
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .q{/../../lib/};
use utf8;

use English qw( -no_match_vars );

use SLight::Test::DataType;
# }}}

use SLight::DataType::Money;

my @validate_tests = (
    {
        name   => 'With some text',
        value  => q{Foo123},
        expect => 'Not a good monetary value',
    },
    {
        name   => 'With spaces',
        value  => q{123 123.23},
        expect => 'Not a good monetary value',
    },
    {
        name   => 'With coma',
        value  => q{123,31},
        expect => 'Not a good monetary value',
    },
);

my @encode_tests = (
    {
        name   => 'Integer',
        value  => '123',
        expect => '123',
    },
    {
        name   => 'Float (1)',
        value  => '123.1',
        expect => '123_1',
    },
    {
        name   => 'Float (2)',
        value  => '123.12',
        expect => '123_12',
    },
    {
        name   => 'Float (3)',
        value  => '123.123',
        expect => '123_123',
    },
);

my @decode_tests = (
    {
        name   => 'Integer',
        value  => '123',
        expect => '123',
    },
    {
        name   => 'Float (1)',
        value  => '123_1',
        expect => '123.1',
    },
    {
        name   => 'Float (2)',
        value  => '123_12',
        expect => '123.12',
    },
    {
        name   => 'Float (3)',
        value  => '123_123',
        expect => '123.123',
    },
);

SLight::Test::DataType::run_tests(
    type => 'Money',

    validate_tests => \@validate_tests,
    encode_tests   => \@encode_tests,
    decode_tests   => \@decode_tests,
);

# vim: fdm=marker
