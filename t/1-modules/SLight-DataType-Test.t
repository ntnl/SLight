#!/usr/bin/perl

# Test for Test DataType
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};
use utf8;

use English qw{ -no_match_vars };

use SLight::Test::DataType;
# }}}

my @validate_tests = (
    {
        name   => 'Failing case',
        value  => "Fail",
        expect => q{Validate failure trigered},
    }
);

my @encode_tests = (
    {
        name   => 'Pass',
        value  => 'Pass',
        expect => 'Pass',
    },
);

my @decode_tests = (
    {
        name   => 'Pass',
        value  => 'Pass',
        expect => 'Pass',
    },
);

SLight::Test::DataType::run_tests(
    type => 'Test',

    validate_tests => \@validate_tests,
    encode_tests   => \@encode_tests,
    decode_tests   => \@decode_tests,
);

# vim: fdm=marker
