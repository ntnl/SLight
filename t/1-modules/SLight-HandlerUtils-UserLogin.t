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

use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use English qw( -no_match_vars );
use Test::More;
# }}}

plan tests =>
    + 1 # Smoke test.
;

require SLight::HandlerUtils::UserLogin;

SLight::HandlerUtils::UserLogin::login(1, 'foo');

ok(1, 'login did not died :)');

# vim: fdm=marker

