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
        'name' => q{1-st level page},
        'path' => [qw( Docs )],
    },
    {
        'name' => q{2-nd level page},
        'path' => [qw( About Authors )],
    },
);

run_pathhandler_tests(
    tests => \@tests,

    ph => 'Page',
);

# vim: fdm=marker
