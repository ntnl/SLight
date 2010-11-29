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

use SLight::AddonBase::CMS::Menu;
use SLight::Test::Site;

use Test::FileReferenced;
use Test::More;
# }}}

plan tests =>
    + 1 # from defaults
    + 1 # from urls
;

#my $site_root = SLight::Test::Site::prepare_fake(
#    test_dir => $Bin . q{/../},
#    site     => 'Minimal'
#);

use SLight::HandlerUtils::Toolbox;

is_referenced_ok(
    SLight::HandlerUtils::Toolbox::make_toolbox(
        urls => [
            {
                action => 'Foo',
            },
        ],

        path_handler => 'Test',
        path         => [ ],

        action   => 'Foo',
        step     => 'view',
        lang     => 'en',
        page     => 1,
        protocol => 'web',

        class => 'TestToolbox',
    ),
    'from defaults'
);

is_referenced_ok(
    SLight::HandlerUtils::Toolbox::make_toolbox(
        urls => [
            {
                path_handler => 'Test',
                path         => [ ],

                action   => 'Foo',
                step     => 'view',
                lang     => 'en',
                page     => 1,
                protocol => 'web',
            },
            {
                path_handler => 'Test',
                path         => [ 'Bar' ],

                action   => 'Bar',
                step     => 'view',
                lang     => 'en',
                page     => 1,
                protocol => 'web',
            },
        ],

        class => 'TestToolbox',
    ),
    'from urls'
);

# vim: fdm=marker

