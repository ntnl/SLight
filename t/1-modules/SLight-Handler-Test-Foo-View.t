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

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

my @tests = (
    {
        'name' => q{Call the 'View' actio non 'Test::Foo' object},
        'url'  => q{/_Test/Foo/},
    },
    {
        # Just a test for test - probably should be moved to separate file! (FIXME)
        'name'     => 'callback test',
        'callback' => sub { return 'OK'; },
        'expect'   => 'scalar',
    }
);

run_handler_tests(
    tests => \@tests,
    
    strip_dates => 1,
);

# vim: fdm=marker
