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
use FindBin qw{ $Bin };
use lib $Bin .'/../../lib/';

use SLight::Core::IO qw( unique_id );
use SLight::Test::Site;

use English qw( -no_match_vars );
use Test::More;
# }}}

plan tests =>
    + 2 # add_EVK
    + 1 # update_EVK
    + 3 # get_EVK
    + 1 # delete_EVK
;

SLight::Test::Site::prepare_empty(
    test_dir => $Bin .q{/../},
);

use SLight::API::EVK qw(
    add_EVK
    update_EVK
    delete_EVK
    get_EVK
);

my $unique_id = unique_id();

my ($k1, $k2);
is(
    $k1 = add_EVK(
        email => q{test@email.test},
        key   => q{F$6G!i3},
    ),
    1,
    q{add_EVK (1/2)},
);
is(
    $k2 = add_EVK(
        email => q{test@mail.ttt},
        key   => $unique_id,

        metadata => {
            foo => q{BarBarBar!}
        }
    ),
    2,
    q{add_EVK (2/2)},
);

is (
    update_EVK(
        id    => $k2,
        email => q{test@mail.tututu},
    ),
    undef,
    q{update_EVK},
);
is_deeply(
    get_EVK($k2),
    {
        id    => $k2,
        email => q{test@mail.tututu},
        key   => $unique_id,
        
        metadata => {
            foo => q{BarBarBar!}
        },
    },
    q{get_EVK (1/3 - as update verification)},
);

ok (
    delete_EVK($k2),
    q{delete_EVK}
);

is (
    get_EVK($k2),
    undef,
    q{get_EVK (2/3 - as delete verification, part one)},
);
is_deeply (
    get_EVK($k1),
    {
        id    => $k1,
        email => q{test@email.test},
        key   => q{F$6G!i3},

        metadata => {
        },
    },
    q{get_EVK (2/3 - as delete verification, part two)},
);

# vim: fdm=marker
