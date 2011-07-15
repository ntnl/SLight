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
use SLight::API::User qw( add_User );

use English qw( -no_match_vars );
use Test::More;
use Test::Exception;
# }}}

plan tests =>
    + 2 # set_User_access
    + 2 # set_System_access
    + 1 # clear_User_access
    + 1 # clear_System_access

    + 4 # get_User_access
    + 4 # get_System_access

    + 5 # can_User_access
;

use SLight::API::Permissions qw(
    set_User_access
    set_System_access
    clear_User_access
    clear_System_access

    get_User_access
    get_System_access

    can_User_access
);

my $site_root = SLight::Test::Site::prepare_empty(
    test_dir => $Bin . q{/../},
);

my $u1 = add_User(
    email  => q{first@test.test},
    pass   => q{Pasłord}, # 'password' spelled in Polish
    status => q{Disabled},
    login  => q{First},
);
my $u2 = add_User(
    email  => q{first@test.test},
    pass   => q{xxxXXXxxx},
    status => q{Guest},
    login  => q{Second},
);

# Set and check some permissions.
is (
    set_User_access(
        id => $u1,

        handler_family => 'Foo',
        handler_class  => 'Bar',
        handler_action => 'Baz',

        handler_object => 123,

        policy => 'GRANTED',
    ),
    undef,
    q{set_User_access}
);
is (
    set_User_access(
        id => $u2,

        handler_family => q{Foo},
        handler_class  => q{*},
        handler_action => q{*},

        handler_object => q{*},

        policy => 'GRANTED',
    ),
    undef,
    q{set_User_access}
);
is (
    get_User_access(
        id => $u1,

        handler_family => 'Foo',
        handler_class  => 'Bar',
        handler_action => 'Baz',

        handler_object => 123,

#        _debug => 1,
    ),
    'GRANTED',
    q{get_User_access}
);
is (
    get_User_access(
        id => $u1,

        handler_family => 'Foo',
        handler_class  => 'Rab',
        handler_action => 'Zib',

        handler_object => 123,
    ),
    undef,
    q{get_User_access}
);

is (
    set_System_access(
        type => q{system},

        handler_family => q{MoinMoin},
        handler_class  => q{*},
        handler_action => q{*},

        policy => 'GRANTED',
    ),
    undef,
    q{set_System_access}
);
is (
    set_System_access(
        type => q{guest},

        handler_family => q{MoinMoin},
        handler_class  => q{Sandbox},
        handler_action => q{*},

        policy => 'DENIED',
    ),
    undef,
    q{set_System_access}
);
is (
    get_System_access(
        type => q{system},

        handler_family => q{MoinMoin},
        handler_class  => q{*},
        handler_action => q{*},

#        _debug => 1,
    ),
    'GRANTED',
    q{get_System_access}
);
is (
    get_System_access(
        type => q{system},

        handler_family => q{ZumZum},
        handler_class  => q{*},
        handler_action => q{*},
    ),
    undef,
    q{get_System_access}
);

# Clear and check permissions
is (
    clear_User_access(
        id => $u2,

        handler_family => q{Foo},
        handler_class  => q{*},
        handler_action => q{*},

        handler_object => q{*},
    ),
    undef,
    q{clear_User_access}
);
is (
    clear_System_access(
        type => 'guest',

        handler_family => q{MoinMoin},
        handler_class  => q{Sandbox},
        handler_action => q{*},
    ),
    undef,
    q{clear_System_access}
);

is (
    get_User_access(
        id => $u2,

        handler_family => q{NiomNiom},
        handler_class  => q{*},
        handler_action => q{*},

        handler_object => q{*},
    ),
    undef,
    q{get_User_access}
);
is (
    get_User_access(
        id => $u2,

        handler_family => 'Foo',
        handler_class  => 'Bar',
        handler_action => 'Baz',

        handler_object => 123,
    ),
    undef,
    q{get_User_access}
);

is (
    get_System_access(
        type => q{system},

        handler_family => q{MoinMoin},
        handler_class  => q{Ziu},
        handler_action => q{Siup},
    ),
    undef,
    q{get_System_access}
);
is (
    get_System_access(
        type => q{guest},

        handler_family => q{MoinMoin},
        handler_class  => q{Aaa},
        handler_action => q{Bbb},
    ),
    undef,
    q{get_System_access}
);

# High level permission checks
is (
    can_User_access(
        id => $u1,

        handler_family => 'Foo',
        handler_class  => 'Bar',
        handler_action => 'Baz',

        handler_object => 123,
    ),
    'GRANTED',
    q{can_User_access}
);
is (
    can_User_access(
        id => $u2,

        handler_family => q{Foo},
        handler_class  => q{Bar},
        handler_action => q{Baz},

        handler_object => q{Ob1},
    ),
    'DENIED',
    q{can_User_access}
);
is (
    can_User_access(
        id => $u1,

        handler_family => q{Foo},
        handler_class  => q{Bar},
        handler_action => q{Baz},

        handler_object => q{Ob1},

#        _debug => 1,
    ),
    'DENIED',
    q{can_User_access}
);

set_System_access(
    type => q{system},

    handler_family => q{FooFoo},
    handler_class  => q{Box},
    handler_action => q{*},

    policy => 'GRANTED',
);
is (
    can_User_access(
        id => undef,

        handler_family => q{FooFoo},
        handler_class  => q{Box},
        handler_action => q{In},

        handler_object => undef,

#        _debug => 1,
    ),
    'GRANTED',
    q{can_User_access (guest)}
);

is (
    can_User_access(
        id => $u2,

        handler_family => q{NiomNiom},
        handler_class  => q{Niom},
        handler_action => q{Niom},

        handler_object => q{Niom},

#        _debug => 1,
    ),
    'DENIED',
    q{can_User_access (user)}
);

# vim: fdm=marker
