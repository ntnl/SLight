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

# Test for Int DataType
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .q{/../../lib/};
use utf8;

use English qw( -no_match_vars );

use SLight::Test::DataType;
# }}}

use SLight::DataType::Int;

my @validate_tests = (
    {
        name   => 'Not a number',
        value  => q{Foo123},
        expect => 'Not a number',
    }
);

my @encode_tests = (
    {
        name   => 'Simple number',
        value  => '123',
        expect => '123',
    },
);

my @decode_tests = (
    {
        name   => 'Simple number',
        value  => '123',
        expect => '123',
    },
);

SLight::Test::DataType::run_tests(
    type => 'Int',

    validate_tests => \@validate_tests,
    encode_tests   => \@encode_tests,
    decode_tests   => \@decode_tests,
);

# vim: fdm=marker
