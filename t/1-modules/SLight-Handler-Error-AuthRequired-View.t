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

use SLight::Test::Site;
use SLight::Test::Handler qw( run_handler_tests );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_empty(
    test_dir => $Bin . q{/../},
);

my @tests = (
    {
        'name' => q{Fake AuthRequired error},
        'url'  => q{/_Test/Object/},
        'cgi'  => {
            't-class' => 'Error::AuthRequired',
            't-oid'   => undef,
        },
    },
);

run_handler_tests(
    tests => \@tests,
    
    strip_dates => 1,

    skip_permissions => 1,
);

# vim: fdm=marker
