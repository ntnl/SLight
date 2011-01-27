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
use SLight::Test::Addon qw( run_addon_tests );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Minimal'
);

my @tests = (
    {
        'name'    => q{Empty path},
        'url'     => q{/},
        'page_id' => 1,
        'meta'    => {},
        'expect'  => 'undef',
    },
    {
        'name'    => q{Path with 1 element},
        'url'     => q{/About/},
        'page_id' => 2,
        'meta'    => {
            path_bar => [
                {
                    class => 'Selected',
                    href  => '/About/',
                    label => 'About this page',
                },
            ],
        },
    },
    {
        'name'    => q{Path with 2 elements},
        'url'     => q{/About/Creator/},
        'page_id' => 3,
        'meta'    => {
            path_bar => [
                {
                    class => 'Parent',
                    href  => '/About/',
                    label => 'About this page',
                },
                {
                    class => 'Selected',
                    href  => '/About/Creator/',
                    label => 'The creator',
                },
            ],
        },
    },
);

run_addon_tests(
    tests => \@tests,

    addon => 'Core::Path',
);

# vim: fdm=marker
