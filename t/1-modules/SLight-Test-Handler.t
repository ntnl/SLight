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

use SLight::Test::Handler;

plan tests =>
    + 1 # smoke test.
;

# At this point, only smoke tests seem necessary.
# This code is heavily used by SLight-Handler-* tests, anyway!

can_ok('SLight::Test::Handler', 'run_handler_tests');

# vim: fdm=marker
