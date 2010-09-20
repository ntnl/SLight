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

use FindBin qw( $Bin );
use lib $Bin .q{/../../lib/};

use SLight::Test::Site::Builder::Test;

SLight::Test::Site::Builder::Test::test_builder(
    $Bin . q{/../../t_data/},
    $Bin . q{/../../sql/0.0/},
    'Minimal',
);

# vim: fdm=marker
