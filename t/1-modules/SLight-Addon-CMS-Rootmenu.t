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

use SLight::Test::Site;
use SLight::Test::Addon qw( run_addon_tests );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Minimal'
);

my @tests = (
    {
        'name'    => q{Root menu},
        'url'     => q{/},
        'page_id' => 1,
        'meta'    => {},
    },
    {
        'name'    => q{Root menu - remains the same},
        'url'     => q{/About/},
        'page_id' => 2,
        'meta'    => {},
    },
);

run_addon_tests(
    tests => \@tests,

    addon => 'CMS::Rootmenu',
);

# vim: fdm=marker
