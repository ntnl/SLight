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
        'name' => q{Login form},
        'url'  => q{/_Authentication/Login.web},
    },
    {
        'name'     => 'Session dump (before fail)',
        'callback' => sub {
            return SLight::Core::Session::part('user');
        },
        'expect' => 'undef',
    },
    {
        'name' => q{Sending form with bad login/pass},
        'url'  => q{/_Authentication/Login-authenticate.web},
        'cgi'  => {
            user => q{foo},
            pass => q{bar},
        },
    },
    {
        'name'     => 'Session dump (before login)',
        'callback' => sub {
            return SLight::Core::Session::part('user');
        },
        'expect' => 'undef',
    },
    {
        'name' => q{Sending form with correct login/pass},
        'url'  => q{/_Authentication/Login-authenticate.web},
        'cgi'  => {
            user => q{aga},
            pass => q{Agniecha},
        },
    },
    {
        'name'     => 'Session dump (after login)',
        'callback' => sub {
            return SLight::Core::Session::part('user');
        },
        'expect' => 'hashref',
    },
);

run_handler_tests(
    tests => \@tests,
);

# vim: fdm=marker
