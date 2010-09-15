#!/usr/bin/perl

# Test for String DataType
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .q{/../../lib/};
use utf8;

use English qw{ -no_match_vars };

use SLight::Test::DataType;
# }}}

my @validate_tests = (
    {
        name   => 'With newlines',
        value  => qq{ Ala\nMa\nKota },
        expect => q{More then one line},
    }
);

my @encode_tests = (
    {
        name   => 'Simple text',
        value  => 'FooBar',
        expect => 'FooBar',
    },
    {
        name   => 'Remove white characters',
        value  => ' Foo Bar Baz ',
        expect => 'Foo Bar Baz',
    },
    {
        name   => 'Remove white characters (begining only)',
        value  => ' Foo Bar Baz',
        expect => 'Foo Bar Baz',
    },
    {
        name   => 'Remove white characters (ending only)',
        value  => 'Foo Bar Baz ',
        expect => 'Foo Bar Baz',
    },
);

my @decode_tests = (
    {
        name   => 'Simple string',
        value  => 'Foo',
        expect => 'Foo',
    },
);

SLight::Test::DataType::run_tests(
    type => 'String',

    validate_tests => \@validate_tests,
    encode_tests   => \@encode_tests,
    decode_tests   => \@decode_tests,
);

# vim: fdm=marker
