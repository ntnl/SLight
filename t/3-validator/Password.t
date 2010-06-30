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
        name   => 'Typical password. OK',
        data   => { foo => 'FooBar' },
        meta   => { foo => { type=>'Password', extras => { 'pass-repeat'=>'FooBar' } } },
        expect => 'undef',
    },
    {
        name   => 'Smallest password - 5 chars. OK',
        data   => { foo => 'ZuzaZ' },
        meta   => { foo => { type=>'Password', extras => { 'pass-repeat'=>'ZuzaZ' } } },
        expect => 'undef',
    },
    
    {
        name   => 'Too short. FAIL',
        data   => { foo => 'Zuza' },
        meta   => { foo => { type=>'Password', extras => { 'pass-repeat'=>'Zuza' } } },
    },
    {
        name   => 'Mismatched - bad letter. FAIL',
        data   => { foo => 'ZuzaZ' },
        meta   => { foo => { type=>'Password', extras => { 'pass-repeat'=>'ZuzaY' } } },
    },
    {
        name   => 'Mismatched - bad case. FAIL',
        data   => { foo => 'ZuzaZ' },
        meta   => { foo => { type=>'Password', extras => { 'pass-repeat'=>'Zuzaz' } } },
    },
);

SLight::Test::Validator::run_tests(
    tests  => \@tests,
);

# vim: fdm=marker
