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

# Check if all code passes PerlCritic level 2 (with some exceptions)
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use SLight::Devel::SmokeTests;

my $path = $Bin . q{/../../lib};

if ($ENV{'COVERAGE_RUN'}) {
    # Just for the module's test..
    $path = $Bin .'/../../lib/SLight/Interface/';
}

SLight::Devel::SmokeTests::perl_critic_test($path, $Bin .'/critic-cache.yaml');


