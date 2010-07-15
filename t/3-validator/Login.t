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
use strict; use warnings; use utf8; # {{{
use FindBin qw{ $Bin };
use lib $Bin . q{/../../lib/};

use SLight::Test::Validator;
use SLight::Test::Site;
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

my @tests = (
    {
        name   => 'Typical login. OK',
        data   => { foo => 'Zuzanna' },
        meta   => { foo => { type=>'Login' } },
        expect => 'undef',
    },
    {
        name   => 'Typical (new) login. OK',
        data   => { foo => 'Zuzanna' },
        meta   => { foo => { type=>'NewLogin' } },
        expect => 'undef',
    },
    {
        name   => 'Smallest login - 4 chars. OK',
        data   => { foo => 'Zuza' },
        meta   => { foo => { type=>'Login' } },
        expect => 'undef',
    },
    
    {
        name   => 'Too short. FAIL',
        data   => { foo => 'Zuz' },
        meta   => { foo => { type=>'Login' } },
    },
    {
        name   => 'Already taken. PASS',
        data   => { foo => 'UserA' },
        meta   => { foo => { type=>'Login' } },
        expect => 'undef',
    },
    {
        name   => 'Already taken. FAIL',
        data   => { foo => 'wanda' },
        meta   => { foo => { type=>'NewLogin' } },
    },
);

SLight::Test::Validator::run_tests(
    tests  => \@tests,
);

# vim: fdm=marker
