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

my $site_root = SLight::Test::Site::prepare_empty(
    test_dir => $Bin . q{/../},
);

# Fixme! Add checks, that verify that User must be logged in!

my @tests = (
    {
        'name' => q{Root (default) page},
        'path' => [ ],
    },
    {
        'name' => q{My data page},
        'path' => [qw( MyData )],
    },
    {
        'name' => q{Avatar properties page},
        'path' => [qw( Avatar )],
    },
    {
        'name' => q{Non-existing page},
        'path' => [qw( Foo Bar )],
    },
);

run_pathhandler_tests(
    tests => \@tests,

    ph => 'MyAccount',
);

# vim: fdm=marker
