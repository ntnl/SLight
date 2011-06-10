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

use SLight::AddonBase::CMS::Menu;
use SLight::Test::Site;

use Test::FileReferenced;
use Test::More;
# }}}

plan tests =>
    + 1 # new()
;

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Minimal'
);

my $fake_addon = SLight::AddonBase::CMS::Menu->new();
# Brute, brute hack...
$fake_addon->{'url'}->{'lang'} = 'en';

isa_ok($fake_addon, 'SLight::AddonBase::CMS::Menu');

# vim: fdm=marker

