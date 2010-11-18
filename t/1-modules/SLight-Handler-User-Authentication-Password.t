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

my $validation_key;

my @tests = (
    {
        'name' => q{Display password recovery form},
        'url'  => q{/_Authentication/Password.web},
    },
    {
        'name' => q{Submit password recovery form},
        'url'  => q{/_Authentication/Password-request.web},
        'cgi'  => {
        }
    },
    {
        'name' => q{Display new password form},
        'url'  => q{/_Authentication/Password-enter.web},
        'cgi'  => {
        }
    },
    {
        'name' => q{Submit password change form},
        'url'  => q{/_Authentication/Password-reset.web},
    },
);

run_handler_tests(
    tests => \@tests,
);

# vim: fdm=marker
