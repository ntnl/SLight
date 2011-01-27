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
use Digest::MD5::File qw( file_md5_hex );
use Test::More;
use Test::Exception;
# }}}

plan tests =>
    + 3 # add_User
    + 1 # update_User

    + 3 # get_User
    + 1 # get_Users
    + 2 # get_User_ids_where
    + 2 # get_Users_where

    + 2 # is_User_registered
    + 2 # check_User_pass
    
    + 2 # delete_User
;

my $site_root = SLight::Test::Site::prepare_empty(
    test_dir => $Bin . q{/../},
);

use SLight::API::User qw(
    add_User
    update_User

    get_User
    get_Users
    get_User_ids_where
    get_Users_where

    is_User_registered
    check_User_pass
    
    delete_User
);

my ( $u1, $u2, $u3 );
is (
    $u1 = add_User(
        email  => q{first@test.test},
        pass   => q{Pasłord}, # 'password' spelled in Polish
        status => q{Disabled},
        login  => q{First},
    ),
    1,
    'add_User (1/3) status: Disabled'
);
is (
    $u2 = add_User(
        email  => q{first@test.test},
        pass   => q{xxxXXXxxx},
        status => q{Guest},
        login  => q{Second},
    ),
    2,
    'add_User (2/3) status: Guest'
);
is (
    $u3 = add_User(
        email  => q{first@test.test},
        pass   => q{123$%^qweRTY},
        status => q{Enabled},
        login  => q{Third},
    ),
    3,
    'add_User (3/3) status: Enabled'
);



is (
    update_User(
        id   => $u1,
        name => 'Initially Added',
    ),
    undef,
    q{update_User}
);



is_deeply (
    get_User($u1),
    {
        id     => $u1,
        name   => 'Initially Added',
        email  => q{first@test.test},
        status => q{Disabled},
        login  => q{First},

        avatar_Asset_id => undef,
    },
    'get_User (1/3)'
);
is_deeply (
    get_User($u2),
    {
        id     => $u2,
        name   => undef,
        email  => q{first@test.test},
        status => q{Guest},
        login  => q{Second},

        avatar_Asset_id => undef,
    },
    'get_User (2/3)'
);
is_deeply (
    get_User($u3),
    {
        id     => $u3,
        name   => undef,
        email  => q{first@test.test},
        status => q{Enabled},
        login  => q{Third},

        avatar_Asset_id => undef,
    },
    'get_User (3/3)'
);



# get_Users

is_deeply (
    get_Users( [ $u1, $u3 ]),
    [
        {
            id     => $u1,
            name   => 'Initially Added',
            email  => q{first@test.test},
            status => q{Disabled},
            login  => q{First},

            avatar_Asset_id => undef,
        },
        {
            id     => $u3,
            name   => undef,
            email  => q{first@test.test},
            status => q{Enabled},
            login  => q{Third},

            avatar_Asset_id => undef,
        },
    ],
    'get_Users'
);



# get_User_ids_where

is_deeply (
    get_User_ids_where(
        login  => q{Third},
        status => q{Superuser}, # Such status does not exist ;)
    ),
    [ ],
    q{get_User_ids_where (1/2)},
);
is_deeply (
    get_User_ids_where(
        login  => q{Third},
        status => q{Enabled},
    ),
    [ $u3 ],
    q{get_User_ids_where (2/2)},
);



# get_Users_where

is_deeply (
    get_Users_where(
        login  => q{Third},
        status => q{Superuser}, # Such status does not exist ;)
    ),
    [ ],
    q{get_Users_where (1/2)},
);
is_deeply (
    get_Users_where(
        login  => q{Third},
        status => q{Enabled},
    ),
    [
        {
            id     => $u3,
            name   => undef,
            email  => q{first@test.test},
            status => q{Enabled},
            login  => q{Third},

            avatar_Asset_id => undef,
        },
    ],
    q{get_Users_where (2/2)},
);



# is_User_registered

is (
    is_User_registered('First'),
    1,
    q{is_User_registered (1/2)}
);
is (
    is_User_registered('Noone'),
    0,
    q{is_User_registered (2/2)}
);



# check_User_pass

is (
    check_User_pass(q{First}, q{Pasłord}),
    $u1,
    q{check_User_pass (1/2)}
);
is (
    check_User_pass(q{First}, q{Hasło}), # 'Hasło' means: Password, in Polish.
    0,
    q{check_User_pass (2/2)}
);

# delete_User

is (
    delete_User($u1),
    1,
    'delete_User'
);
is (
    get_User($u1),
    undef,
    'delete_User (actual check)'
);

# vim: fdm=marker
