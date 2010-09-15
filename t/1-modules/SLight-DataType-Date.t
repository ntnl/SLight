#!/usr/bin/perl

# Test for Date DataType
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .q{/../../lib/};
use utf8;

use English qw{ -no_match_vars };

use SLight::Test::DataType;
# }}}

my @validate_tests = (
    {
        name   => 'Junk',
        value  => q{Ala Ma Kota},
        expect => q{Not a valid date string},
    }
);

# 1218924000 == 2008-08-17

my @encode_tests = (
    {
        name   => 'Date',
        value  => '2008-08-17',
        expect => '1218924000',
    },
);

my @decode_tests = (
    {
        name   => 'Date',
        value  => '1218966591',
        expect => '2008-08-17',
    },
);

SLight::Test::DataType::run_tests(
    type => 'Date',

    validate_tests => \@validate_tests,
    encode_tests   => \@encode_tests,
    decode_tests   => \@decode_tests,
);

# vim: fdm=marker

