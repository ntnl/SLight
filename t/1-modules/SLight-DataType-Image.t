#!/usr/bin/perl

# Test for Image DataType
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .q{/../../lib/};
use utf8;

use English qw{ -no_match_vars };

use SLight::Test::DataType;
# }}}

use SLight::DataType::Image;

my @validate_tests = ();

my @encode_tests = (
    {
        name   => 'Passes trough',
        value  => 'foo BAR baz',
        expect => 'foo BAR baz',
    },
);

my @decode_tests = (
    {
        name   => 'Passes trough',
        value  => 'foo BAR baz',
        expect => 'foo BAR baz',
    },
);

SLight::Test::DataType::run_tests(
    type => 'Image',

    validate_tests => \@validate_tests,
    encode_tests   => \@encode_tests,
    decode_tests   => \@decode_tests,
);

# vim: fdm=marker
