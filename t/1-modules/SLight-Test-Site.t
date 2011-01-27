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

use Test::More;
use Test::Exception;
use utf8;
# }}}

use SLight::Test::Site;

plan tests =>
    + 1 # prepare_place
    + 1 # prepare_empty
    + 1 # prepare_fake
;

# Additional tests may be added here later...

like (
    SLight::Test::Site::prepare_place(
        test_dir => $Bin . q{/../},
    ),
    qr{/SLight_TestSite/\d+/},
    qw{prepare_place()},
);

like (
    SLight::Test::Site::prepare_empty(
        test_dir => $Bin . q{/../},
    ),
    qr{/SLight_TestSite/\d+/},
    qw{prepare_place()},
);

like (
    SLight::Test::Site::prepare_fake(
        test_dir => $Bin . q{/../},
        site     => 'Users'
    ),
    qr{/SLight_TestSite/\d+/},
    qw{prepare_place()},
);

# vim: fdm=marker
