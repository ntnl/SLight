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
        'name'    => q{Sub menu on root},
        'url'     => q{/},
        'page_id' => 1,
        'meta'    => {},
        'expect'  => 'undef',
    },
    {
        'name'    => q{Sub menu on 1-st level page},
        'url'     => q{/About/},
        'page_id' => 2,
        'meta'    => {},
        'expect'  => 'undef',
    },
    {
        'name'    => q{Sub menu on 2-st level page},
        'url'     => q{/About/Authors/},
        'page_id' => 5,
        'meta'    => {},
    },
);

run_addon_tests(
    tests => \@tests,

    addon => 'CMS::Submenu',
);

# vim: fdm=marker
