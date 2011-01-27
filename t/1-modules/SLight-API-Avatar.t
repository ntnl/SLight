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
use File::Slurp qw( read_file );
use Test::More;
use Test::Exception;
# }}}

plan tests =>
    + 1 # set_Avatar
    + 2 # get_Avatar
    + 1 # delete_Avatar
;

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

use SLight::API::Avatar qw(
    set_Avatar
    get_Avatar
    delete_Avatar
);

my $image_gif = read_file($Bin .q{/../SampleImage.gif});

is (
    set_Avatar(4, $image_gif),
    2,
    q{set_Avatar}
);

is_deeply (
    [ get_Avatar(4) ],
    [ $image_gif, q{image/gif} ],
    q{get_Avatar (existing)}
);

is (
    delete_Avatar(4),
    undef,
    q{delete_Avatar}
);

is_deeply (
    [ get_Avatar(4) ],
    [ undef, undef ],
    q{get_Avatar (missing)}
);

# vim: fdm=marker
