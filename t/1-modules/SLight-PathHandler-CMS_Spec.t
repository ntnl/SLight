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

use SLight::Test::Site;
use SLight::Test::PathHandler qw( run_pathhandler_tests );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Minimal'
);

my @tests = (
    {
        'name' => q{Root page},
        'path' => [ ],
    },
    {
        'name' => q{Spec page},
        'path' => [qw( Spec 1 )],
    },
    {
        'name' => q{Field page},
        'path' => [qw( Field 1 title )],
    },
);

run_pathhandler_tests(
    tests => \@tests,

    ph => 'CMS_Spec',
);

# vim: fdm=marker
