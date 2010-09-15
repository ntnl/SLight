#!/usr/bin/perl
################################################################################
# 
# SLight - Lightweight Content Manager System.
#
# Copyright (C) 2010 Bartłomiej /Natanael/ Syguła
#
# This is free software.
# It is licensed, and can be distributed under the same terms as Perl itself.
#
# More information on: http://slight-cms.org/
# 
################################################################################

# Test for Link DataType
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .q(/../../lib/);
use utf8;

use English qw( -no_match_vars );

use SLight::Test::DataType;
# }}}

use SLight::DataType::Link;

my @validate_tests = (
    {
        name   => 'Junk',
        value  => q{Foo123Bar},
        expect => 'Not a link',
    }
);

my @encode_tests = (
    {
        name   => 'HTTP link',
        value  => 'http://foo.bar/baz',
        expect => 'http://foo.bar/baz',
    },
    {
        name   => 'HTTP domain link',
        value  => 'http://foo.bar/',
        expect => 'http://foo.bar/',
    },
    {
        name   => 'HTTP SSL link',
        value  => 'https://foo.bar/baz',
        expect => 'https://foo.bar/baz',
    },
    {
        name   => 'FTP link',
        value  => 'ftp://foo.bar/baz',
        expect => 'ftp://foo.bar/baz',
    },
);

my @decode_tests = (
    {
        name   => 'HTTP link',
        value  => 'http://foo.bar/baz',
        expect => 'http://foo.bar/baz',
    },
    {
        name   => 'HTTP domain link',
        value  => 'http://foo.bar/',
        expect => 'http://foo.bar/',
    },
    {
        name   => 'HTTP SSL link',
        value  => 'https://foo.bar/baz',
        expect => 'https://foo.bar/baz',
    },
    {
        name   => 'FTP link',
        value  => 'ftp://foo.bar/baz',
        expect => 'ftp://foo.bar/baz',
    },
);

SLight::Test::DataType::run_tests(
    type => 'Link',

    validate_tests => \@validate_tests,
    encode_tests   => \@encode_tests,
    decode_tests   => \@decode_tests,
);

# vim: fdm=marker
