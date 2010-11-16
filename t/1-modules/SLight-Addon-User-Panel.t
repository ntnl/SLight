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
use SLight::Test::Addon qw( run_addon_tests );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

my @tests = (
    {
        'name'    => q{Not logged in},
        'url'     => q{/},
        'page_id' => 1,
        'meta'    => {},
        'user'    => undef,
    },
    {
        'name'    => q{Logged in},
        'url'     => q{/},
        'page_id' => 1,
        'meta'    => {},
        'session' => {
            'user' => {
                login => 'aga',
                id    => 1,
            },
        },
    },
);

run_addon_tests(
    tests => \@tests,

    addon => 'User::Panel',
);

# vim: fdm=marker
