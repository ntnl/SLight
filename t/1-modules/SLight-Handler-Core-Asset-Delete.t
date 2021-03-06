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
use SLight::Test::Handler qw( run_handler_tests );

use English qw( -no_match_vars );
use File::Slurp qw( read_file );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Minimal'
);

my @tests = (
    {
        'name' => q{Ask for confirmation of Asset deletion},
        'url'  => q{/_Asset/Asset/2/Delete.web},
    },
    {
        'name' => q{Commit Asset deletion},
        'url'  => q{/_Asset/Asset/2/Delete-commit.web},
    },
    {
        'name'      => q{Confirm Asset deletion},
        'sql_query' => [ 'SELECT id FROM Asset_Entity' ],
        'expect'    => 'arrayref',
    }
);

run_handler_tests(
    tests => \@tests,

#    strip_dates => 1,

    skip_permissions => 1,
);

# vim: fdm=marker
