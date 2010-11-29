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
        name   => 'Time OK',
        data   => { foo => q{12:30:00} },
        meta   => { foo => { type=>'ISO_Time' } },
        expect => 'undef',
    },

    {
        name   => 'Time with letters. FAIL',
        data   => { foo => qq{Now.} },
        meta   => { foo => { type=>'ISO_Date' } },
    },
);

SLight::Test::Validator::run_tests(
    tests  => \@tests,
);

# vim: fdm=marker
