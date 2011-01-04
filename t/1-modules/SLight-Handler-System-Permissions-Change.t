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
        'name' => q{Deny access to all CMS actions on system level},
        'url'  => q{/_Permissions/Change-deny.web},
        'cgi'  => {
            level => q{system},

            h_family => q{CMS},
            h_class  => q{*},
            h_action => q{*},
        },
    },
    {
        'name' => q{Allow access to all User/Authentication actions for guests},
        'url'  => q{/_Permissions/Change-grant.web},
        'cgi'  => {
            level => q{guest},

            h_family => q{User},
            h_class  => q{Authentication},
            h_action => q{*},
        },
    },
    {
        'name'      => q{Check what was put into DB.},
        'sql_query' => [q{SELECT * FROM System_Access}],
    },
);

run_handler_tests(
    tests => \@tests,

    skip_permissions => 1,
);

# vim: fdm=marker

