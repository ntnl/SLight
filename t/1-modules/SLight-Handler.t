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
use utf8;
# }}}

plan tests =>
    + 5 # most-simple smoke tests.
;

require SLight::Handler;

# This should be sufficient for some time...

can_ok('SLight::Handler', 'new');
can_ok('SLight::Handler', 'handle');
can_ok('SLight::Handler', 'is_main_object');
can_ok('SLight::Handler', 'set_class');
can_ok('SLight::Handler', 'push_data');

# vim: fdm=marker
