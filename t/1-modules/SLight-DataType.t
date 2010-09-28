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

# Test for SLight::DataType
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .q{/../../lib/};

use Test::More;
use Test::Exception;
use utf8;
# }}}

use SLight::DataType;

plan tests =>
    + 1 # 'siganture' crash tests.
;

# 'siganture' crash tests.
dies_ok {
    SLight::DataType::signature( type=>'Foo' );
} "Function: 'siganture' handles bogus types corectly";

# vim: fdm=marker
