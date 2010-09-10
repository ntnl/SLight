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
    site     => 'Users'
);

my @tests = (
    {
        name => q{New spec form},
        url  => q{/_CMS_Spec/Spec/New.web},
    },
    {
        name => q{Save new spec form},
        url  => q{/_CMS_Spec/Spec/New-save.web},
        cgi  => {
            caption => 'Foo spec'
        }
    },
);

run_handler_tests(
    tests => \@tests,
);

# vim: fdm=marker
