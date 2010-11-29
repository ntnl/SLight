#!/usr/bin/perl
################################################################################
# 
# SLight - Lightweight Content Management System.
#
# Copyright (C) 2010 Bartłomiej /Natanael/ Syguła
#
# This is free software.
# It is licensed, and can be distributed under the same terms as Perl itself.
#
# More information on: http://slight-cms.org/
# 
################################################################################

# Test for Time DataType
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .q{/../../lib/};
use utf8;

use English qw( -no_match_vars );

use SLight::Test::DataType;
# }}}

my @validate_tests = (
    {
        name   => 'Junk',
        value  => q{Ala Ma Kota},
        expect => q{Not a valid date/time string},
    }
);

# 1218966540 == 2008-08-17 11:49:00
# 1218966591 == 2008-08-17 11:49:51

my @encode_tests = (
    {
        name   => 'Time with seconds',
        value  => '2008-08-17 11:49:51',
        expect => '1218966591',
    },
    {
        name   => 'Time without seconds',
        value  => '2008-08-17 11:49',
        expect => '1218966540',
    },
);

my @decode_tests = (
    {
        name   => 'Time with seconds',
        value  => '1218966591',
        expect => '2008-08-17 11:49:51',
    },
    {
        name   => 'Time without seconds',
        value  => '1218966540',
        expect => '2008-08-17 11:49',
    },
);

SLight::Test::DataType::run_tests(
    type => 'Time',

    validate_tests => \@validate_tests,
    encode_tests   => \@encode_tests,
    decode_tests   => \@decode_tests,
);

# vim: fdm=marker

