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
        'name' => q{Show dialog},
        'url'  => q{/_Account/beti/Account/Delete.web},
    },
    {
        'name' => q{Submit request},
        'url'  => q{/_Account/beti/Account/Delete-commit.web},
    },
    {
        'name'      => q{Check what was deleted},
        'sql_query' => [q{SELECT * FROM User_Entity WHERE id IN (1, 2, 3)}],
    },
);

run_handler_tests(
    tests => \@tests,

    skip_permissions => 1,
);

# vim: fdm=marker
