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
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use Test::More;
# }}}

use SLight::Protocol::WEB_TEST;

plan tests =>
    + 1 # smoke tests
;

can_ok('SLight::Protocol::WEB_TEST', 'new');

# vim: fdm=marker
