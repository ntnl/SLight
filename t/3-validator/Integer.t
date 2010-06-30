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
        name   => '1 digit. OK',
        data   => { foo => 1 },
        meta   => { foo => { type=>'Integer' } },
        expect => 'undef',
    },
    {
        name   => '2 digits. OK',
        data   => { foo => 12 },
        meta   => { foo => { type=>'Integer' } },
        expect => 'undef',
    },
    {
        name   => '3 digits. OK',
        data   => { foo => 123 },
        meta   => { foo => { type=>'Integer' } },
        expect => 'undef',
    },
    
    {
        name   => '2 digits with "-". OK',
        data   => { foo => '-123' },
        meta   => { foo => { type=>'Integer' } },
        expect => 'undef',
    },
    {
        name   => '2 digits with "+". OK',
        data   => { foo => '+123' },
        meta   => { foo => { type=>'Integer' } },
        expect => 'undef',
    },

    {
        name   => 'Float. FAIL',
        data   => { foo => '1.23' },
        meta   => { foo => { type=>'Integer' } },
    },
    {
        name   => 'String. FAIL',
        data   => { foo => 'foo' },
        meta   => { foo => { type=>'Integer' } },
    },
);

SLight::Test::Validator::run_tests(
    tests  => \@tests,
);

# vim: fdm=marker
