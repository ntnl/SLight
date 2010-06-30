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
use strict; use warnings; use utf8; # {{{
use FindBin qw{ $Bin };
use lib $Bin .'/../../lib/';

use SLight::Test::Validator;
# }}}

my @tests = (
    {
        name   => 'Empty string. OK',
        data   => { foo => q{} },
        meta   => { foo => { type=>'ASCII', optional=>1 } },
        expect => 'undef',
    },
    {
        name   => 'Typical string. OK',
        data   => { foo => 'Foo123' },
        meta   => { foo => { type=>'ASCII' } },
        expect => 'undef',
    },

    {
        name   => 'Cointains punctation. FAIL',
        data   => { foo => qq{Foo.Bar} },
        meta   => { foo => { type=>'ASCII' } },
    },
    {
        name   => 'Cointains space. FAIL',
        data   => { foo => qq{Foo Bar} },
        meta   => { foo => { type=>'ASCII' } },
    },
    {
        name   => 'Cointains newline. FAIL',
        data   => { foo => qq{Foo\nBar} },
        meta   => { foo => { type=>'ASCII' } },
    },
    {
        name   => 'Cointains tab. FAIL',
        data   => { foo => qq{Foo\tBar} },
        meta   => { foo => { type=>'ASCII' } },
    },
    {
        name   => 'Cointains c.return. FAIL',
        data   => { foo => qq{Foo\rBar} },
        meta   => { foo => { type=>'ASCII' } },
    },
    {
        name   => 'Cointains zero-byte. FAIL',
        data   => { foo => qq{Foo\0Bar} },
        meta   => { foo => { type=>'ASCII' } },
    },
);

SLight::Test::Validator::run_tests(
    tests  => \@tests,
);

# vim: fdm=marker
