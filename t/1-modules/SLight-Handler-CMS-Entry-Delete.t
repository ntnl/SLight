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
use SLight::Test::Handler qw( run_handler_tests );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Minimal'
);

my @tests = (
    {
        'name'      => q{List pages - before},
        'sql_query' => [ "SELECT id, parent_id FROM Page_Entity ORDER BY id" ],
        'expect'    => 'arrayref',
    },
    {
        'name' => q{Open confirmation dialog},
        'url'  => q{/About/Delete.web},
    },
    {
        'name' => q{Actually delete the page},
        'url'  => q{/About/Delete-commit.web},
    },
    {
        'name'      => q{List pages - after},
        'sql_query' => [ "SELECT id, parent_id FROM Page_Entity ORDER BY id" ],
        'expect'    => 'arrayref',
    },
);

run_handler_tests(
    tests => \@tests,
    
    strip_dates => 1,
);

# vim: fdm=marker
