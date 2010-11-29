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
        'name' => q{User 'aga', status: Enabled},
        'url'  => q{/_MyAccount/},

        'session' => {
            'user' => {
                login => 'aga',
                id    => 1,
            },
        },
    },
    {
        'name' => q{User 'nataly', status: Guest},
        'url'  => q{/_MyAccount/},

        'session' => {
            'user' => {
                login => 'nataly',
                id    => 4,
            }
        },
    },
    {
        'name' => q{User 'wanda', status: Disabled},
        'url'  => q{/_MyAccount/},

        'session' => {
           'user' => {
               login => 'wanda',
               id    => 5,
           }
        },
    },
);

run_handler_tests(
    tests => \@tests,
);

# vim: fdm=marker
