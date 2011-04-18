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

use English qw( -no_match_vars );
use Test::More;
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Minimal'
);

plan tests =>
    2
;

require SLight::PathHandlerUtils;

is_deeply(
    SLight::PathHandlerUtils::get_path_target(q{Page}, [ ]),
    {
        handler => 'CMS::Entry',
        id      => 1,
    },
    'Root Page'
);

is_deeply(
    SLight::PathHandlerUtils::get_path_target(q{Page}, [qw( About )]),
    {
        handler => 'CMS::Entry',
        id      => 2,
    },
    'First level Page'
);

# vim: fdm=marker
