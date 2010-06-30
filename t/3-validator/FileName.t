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
        name   => 'Letters. OK',
        data   => { file => 'Foo' },
        meta   => { file => { type=>'FileName' } },
        expect => 'undef',
    },
    {
        name   => 'Letters and digits. OK',
        data   => { file => 'Foo123' },
        meta   => { file => { type=>'FileName' } },
        expect => 'undef',
    },
    {
        name   => 'Letters with some punctation. OK',
        data   => { file => 'Foo_Bar-1.baz' },
        meta   => { file => { type=>'FileName' } },
        expect => 'undef',
    },
    
    {
        name   => 'Spaces. FAIL',
        data   => { file => 'A B C' },
        meta   => { file => { type=>'FileName' } },
    },
    {
        name   => 'Slash. FAIL',
        data   => { file => 'Foo/Bar.baz' },
        meta   => { file => { type=>'FileName' } },
    },
);

SLight::Test::Validator::run_tests(
    tests  => \@tests,
);

# vim: fdm=marker
