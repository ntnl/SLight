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
        name   => 'Domain only. OK',
        data   => { foo => q{http://foo.bar} },
        meta   => { foo => { type=>'URL' } },
        expect => 'undef',
    },
    {
        name   => 'Domain tailed with "/". OK',
        data   => { foo => q{http://foo.bar/} },
        meta   => { foo => { type=>'URL' } },
        expect => 'undef',
    },
    {
        name   => 'Domain and URI. OK',
        data   => { foo => q{http://foo.bar/baz} },
        meta   => { foo => { type=>'URL' } },
        expect => 'undef',
    },

    {
        name   => 'String. FAIL',
        data   => { foo => 'foo' },
        meta   => { foo => { type=>'URL' } },
    },
);

SLight::Test::Validator::run_tests(
    tests  => \@tests,
);

# vim: fdm=marker
