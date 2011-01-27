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

use SLight::API::Avatar qw( delete_Avatar );
use SLight::API::Asset qw( add_Asset );
use SLight::Test::Site;
use SLight::Test::Handler qw( run_handler_tests );

use File::Slurp qw( read_file );
use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

delete_Avatar(3);

my @tests = (
    {
        'name' => q{Empty Asset list},
        'url'  => q{/_Asset/},
    },
    {
        'name' => q{Asset list with one asset},
        'url'  => q{/_Asset/},

        'call_before' => sub {
            add_Asset(
                data => scalar read_file($Bin . q{/../SampleImage.png}),

                email => 'test@test.test',

                filename => 'SampleImage.png',
                summary  => 'Sample image for testing purposes.',
            );
        }
    }
);

run_handler_tests(
    tests => \@tests,

#    strip_dates => 1,

    skip_permissions => 1,
);

# vim: fdm=marker
