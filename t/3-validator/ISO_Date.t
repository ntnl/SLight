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
        name   => 'Date OK',
        data   => { foo => q{2001-10-11} },
        meta   => { foo => { type=>'ISO_Date' } },
        expect => 'undef',
    },

    {
        name   => 'Date with letters. FAIL',
        data   => { foo => qq{Friday, 10 October 2005} },
        meta   => { foo => { type=>'ISO_Date' } },
    },
);

SLight::Test::Validator::run_tests(
    tests  => \@tests,
);

# vim: fdm=marker
