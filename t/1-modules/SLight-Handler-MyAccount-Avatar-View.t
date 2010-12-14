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

use SLight::API::Avatar qw( set_Avatar );
use SLight::Test::Site;
use SLight::Test::Handler qw( run_handler_tests );

use English qw( -no_match_vars );
use File::Slurp qw( read_file );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

my @tests = (
    {
        'name' => q{Off-site avatar (Gravatar)},
        'url'  => q{/_MyAccount/Avatar/},

        'session' => {
            'user' => {
                login => 'aga',
                id    => 1,
            },
        },
    },
    {
        'name' => q{On-site avatar},
        'url'  => q{/_MyAccount/Avatar/},

        'session' => {
            'user' => {
                login => 'ela',
                id    => 3,
            },
        },
    },
);

run_handler_tests(
    tests => \@tests,

#    strip_dates => 1,
);

# vim: fdm=marker
