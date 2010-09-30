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
use lib $Bin . q{/../../lib/};

use Test::More;
use Test::Exception;
use utf8;
# }}}

use SLight::Test::Runner;

plan tests =>
    + 1 # smoke test.
;

# Additional tests may be added here later...

can_ok('SLight::Test::Runner', 'run_tests');

# vim: fdm=marker
