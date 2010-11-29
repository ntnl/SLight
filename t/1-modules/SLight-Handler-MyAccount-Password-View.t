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
        'name'    => q{Show form},
        'url'     => q{/_MyAccount/Password/},
        'session' => {
            user => {
                login => 'beti',
                id    => 2,
            },
        },
    },
    {
        'name'      => q{Check before updated},
        'sql_query' => [q{SELECT * FROM User_Entity WHERE id IN (1, 2, 3)}],
    },
    {
        'name' => q{Submit form (bad data)},
        'url'  => q{/_MyAccount/Password/View-save.web},
        'cgi'  => {
            'pass'        => q{1234567890qwertyuiopasdfghjklzxcvbnm1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik9ol0p},
            'pass-repeat' => q{qazwsxedcrfvtgbyhnujmiklop},
        },
    },
    {
        'name' => q{Submit form (good data)},
        'url'  => q{/_MyAccount/Password/View-save.web},
        'cgi'  => {
            'pass'        => q{OneTwoThree},
            'pass-repeat' => q{OneTwoThree},
        },
    },
    {
        'name'      => q{Check what was updated},
        'sql_query' => [q{SELECT * FROM User_Entity WHERE id IN (1, 2, 3)}],
    },
);

run_handler_tests(
    tests => \@tests,
);

# vim: fdm=marker
