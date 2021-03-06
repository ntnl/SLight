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
        'name'      => q{Check - before},
        'sql_query' => [ 'SELECT id FROM Asset_Entity' ],
        'expect'    => 'arrayref',
    },
    {
        'name' => q{Display form},
        'url'  => q{/_Account/beti/Avatar/Change.web},
    },
    {
        'name' => q{Upload image},
        'url'  => q{/_Account/beti/Avatar/Change-save.web},
        'cgi'  => {
            'avatar' => scalar read_file($Bin . q{/../SampleImage.gif}),
        },
    },
    {
        'name'      => q{Check - after},
        'sql_query' => [ 'SELECT id FROM Asset_Entity' ],
        'expect'    => 'arrayref',
    },
    {
        'name'      => q{Check - user},
        'sql_query' => [ 'SELECT * FROM User_Entity WHERE id = 2' ],
        'expect'    => 'arrayref',
    },
);

run_handler_tests(
    tests => \@tests,

#    strip_dates => 1,

    skip_permissions => 1,
);

# vim: fdm=marker
