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

use SLight::Core::Session;
use SLight::Test::Site;
use SLight::Test::Handler qw( run_handler_tests );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

my @tests = (
    {
        'name'     => 'Session dump (before)',
        'callback' => sub {
            SLight::Core::Session::part_set(
                'user',
                {
                    login => 'aga',
                    id    => 1,
                },
            );

            return SLight::Core::Session::part('user');
        },
        'expect' => 'hashref',
    },
    {
        'name' => q{Logout},
        'url'  => q{/_Authentication/Logout.web},
    },
    {
        'name'     => 'Session dump (after)',
        'callback' => sub {
            return SLight::Core::Session::part('user');
        },
        'expect' => 'hashref',
    },
);

run_handler_tests(
    tests => \@tests,

    skip_permissions => 1,
);

# vim: fdm=marker
