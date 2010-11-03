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

use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .'/../../lib/';

use SLight::Test::DataStructure qw( run_datastructure_tests );

use English qw( -no_match_vars );
# }}}

my %tests = (
    'simple usage' => {
        tests => [], # None actually.
    },
);

run_datastructure_tests(
    tests => \%tests,

    structure => 'Token'
);

# vim: fdm=marker
