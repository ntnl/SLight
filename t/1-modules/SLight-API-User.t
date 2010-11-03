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

use English qw( -no_match_vars );
use File::Slurp qw( read_file );
use Digest::MD5::File qw( file_md5_hex );
use Test::More;
use Test::Exception;
# }}}

plan tests =>
    + 3 # add_User
    + 1 # update_User
    + 3 # get_User
    + 1 # delete_User
    + 1 # is_User_registered
    + 1 # check_User_pass
;

my $site_root = SLight::Test::Site::prepare_empty(
    test_dir => $Bin . q{/../},
);

use SLight::API::User qw(
    add_User
    update_User
    get_User
    delete_User
    is_User_registered
    check_User_pass
);

my ( $u1, $u2, $u3 );
is (
    $u1 = add_User(
    ),
    1,
    'add_User (1/3) status: Disabled'
);
is (
    $u2 = add_User(
    ),
    2,
    'add_User (2/3) status: Guest'
);
is (
    $u3 = add_User(
    ),
    3,
    'add_User (3/3) status: Enabled'
);



# vim: fdm=marker
