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
use strict; use warnings; use utf8; # {{{
use FindBin qw{ $Bin };
use lib $Bin .'/../../lib/';

use SLight::Test::Validator;
# }}}

my @tests = (
    {
        name   => 'Date with time OK',
        data   => { foo => q{2001-10-11 12:30:00} },
        meta   => { foo => { type=>'ISO_DateTime' } },
        expect => 'undef',
    },

    {
        name   => 'Human-readable date and time. FAIL',
        data   => { foo => qq{Friday, 10 October 2005, at noon} },
        meta   => { foo => { type=>'ISO_DateTime' } },
    },
);

SLight::Test::Validator::run_tests(
    tests  => \@tests,
);

# vim: fdm=marker
