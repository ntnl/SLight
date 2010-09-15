#!/usr/bin/perl

# Test for Link DataType
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .q{/../../lib/};
use utf8;

use English qw{ -no_match_vars };

use SLight::Test::DataType;
# }}}

use SLight::DataType::Link;

my @validate_tests = (
    {
        name   => 'Junk',
        value  => q{Foo123Bar},
        expect => 'Not an email',
    }
);

my @encode_tests = (
    {
        name   => 'Email address',
        value  => 'foo.foo@bar.baz.com',
        expect => 'foo.foo@bar.baz.com',
    },
);

my @decode_tests = (
    {
        name   => 'Email address',
        value  => 'foo.foo@bar.baz.com',
        expect => 'foo.foo@bar.baz.com',
    },
);

SLight::Test::DataType::run_tests(
    type => 'Email',

    validate_tests => \@validate_tests,
    encode_tests   => \@encode_tests,
    decode_tests   => \@decode_tests,
);

# vim: fdm=marker
