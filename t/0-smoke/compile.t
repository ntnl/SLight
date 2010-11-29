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

# Check if all code can be compiled without problems.
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use SLight::Devel::SmokeTests;

my @paths = (
    $Bin .'/../../scripts/',
    $Bin .'/../../lib/',
    $Bin .'/../../t/',
);

if ($ENV{'COVERAGE_RUN'}) {
    # Just for the module's test..
    @paths = ( $Bin .'/../../SLight/Interface/' );
}

SLight::Devel::SmokeTests::compilation_test(
    \@paths,
);

# vim: fdm=marker
