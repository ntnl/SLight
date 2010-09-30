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

use SLight::Test::Validator;
use utf8;
# }}}

SLight::Test::Validator::check_module(
    $Bin . q{/../},
    $Bin . q{/../../lib/SLight/Validator/User.pm},
);

# vim: fdm=marker
