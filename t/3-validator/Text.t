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
use strict; use warnings; use utf8; # {{{
use FindBin qw{ $Bin };
use lib $Bin .'/../../lib/';

use SLight::Test::Validator;
# }}}

my @tests = (
    {
        name   => 'Empty string. OK',
        data   => { foo => q{} },
        meta   => { foo => { type=>'Text', optional=>1 } },
        expect => 'undef',
    },
    {
        name   => 'Typical string. OK',
        data   => { foo => "Foo\n\rBar" },
        meta   => { foo => { type=>'Text' } },
        expect => 'undef',
    },

    {
        name   => 'Cointains tab. FAIL',
        data   => { foo => qq{Foo\tBar} },
        meta   => { foo => { type=>'Text' } },
    },
    {
        name   => 'Cointains zero-byte. FAIL',
        data   => { foo => qq{Foo\0Bar} },
        meta   => { foo => { type=>'Text' } },
    },
);

SLight::Test::Validator::run_tests(
    tests  => \@tests,
);

# vim: fdm=marker
