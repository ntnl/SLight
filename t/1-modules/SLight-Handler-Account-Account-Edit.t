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
        'name' => q{Show form},
        'url'  => q{/_Account/beti/Account/Edit-pl.web},
    },
    {
        'name' => q{Submit form (bad data)},
        'url'  => q{/_Account/beti/Account/Edit-save-pl.web},
        'cgi'  => {
            'u-name'   => q{1234567890qwertyuiopasdfghjklzxcvbnm1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik9ol0p},
            'u-email'  => q{foo@bar@baz},
            'u-status' => q{New},
        },
    },
    {
        'name'      => q{Check before updated},
        'sql_query' => [q{SELECT * FROM User_Entity WHERE id IN (1, 2, 3)}],
    },
    {
        'name' => q{Submit form (good data)},
        'url'  => q{/_Account/beti/Account/Edit-save-pl.web},
        'cgi'  => {
            'u-name'   => q{Beate},
            'u-email'  => q{bb@bar.test},
            'u-status' => q{Guest},
        },
    },
    {
        'name'      => q{Check what was updated},
        'sql_query' => [q{SELECT * FROM User_Entity WHERE id IN (1, 2, 3)}],
    },
);

run_handler_tests(
    tests => \@tests,

    skip_permissions => 1,
);

# vim: fdm=marker
