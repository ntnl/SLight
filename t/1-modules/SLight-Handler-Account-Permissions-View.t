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

use SLight::API::Permissions qw( set_System_access set_User_access );
use SLight::HandlerMeta;
use SLight::Test::Site;
use SLight::Test::Handler qw( run_handler_tests );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

SLight::HandlerMeta::set_handlers_list(
    [
        {
            'objects' => [
                {
                    'actions' => [qw( Change View )],
                    'class'   => 'Permissions',
                }
            ],
            'class' => 'System',
        },
        {
            'objects' => [
                {
                    'actions' => [qw( Register Logout Login Password ActivateAccount )],
                    'class' => 'Authentication',
                },
                {
                    'actions' => [qw( View )],
                    'class' => 'Avatar',
                }
            ],
            'class' => 'User',
        },
        {
            'objects' => [
                {
                    'actions' => [qw( View )],
                    'class' => 'List',
                },
                {
                    'actions' => [qw( Change View )],
                    'class' => 'Permissions',
                },
                {
                    'actions' => [qw( Edit New Password View Delete )],
                    'class' => 'Account',
                },
                {
                    'actions' => [qw( Change View Delete )],
                    'class' => 'Avatar',
                }
            ],
            'class' => 'Account',
        },
        {
            'objects' => [
                {
                    'actions' => [qw( View )],
                    'class' => 'Password',
                },
                {
                    'actions' => [qw( Edit View )],
                    'class' => 'MyData',
                },
                {
                    'actions' => [qw( Change View Delete )],
                    'class' => 'Avatar',
                }
            ],
            'class' => 'MyAccount',
        },
        {
            'objects' => [
                {
                    'actions' => [qw( View )],
                    'class' => 'Object',
                },
                {
                    'actions' => [qw( View )],
                    'class' => 'Foo',
                }
            ],
            'class' => 'Test',
        },
        {
            'objects' => [
            {
                'actions' => [qw( AddContent View Delete )],
                'class'   => 'Empty',
            },
            {
                'actions' => [qw( Thumb View Download Delete )],
                'class'   => 'Asset',
            },
            {
                'actions' => [qw( View )],
                'class'   => 'AssetList',
            }
            ],
                'class' => 'Core',
        }
    ]
);

# Set some permissions :)
# Use case 1-a - Family * * - on system level
set_System_access( type => 'system',   handler_family => q{User},      handler_class  => q{*}, handler_action => q{*},  policy => 'GRANTED' );
set_System_access( type => 'system',   handler_family => q{MyAccount}, handler_class  => q{*}, handler_action => q{*},  policy => 'DENIED' );

# Use case 2-a - Family Class * - on system level
set_System_access( type => 'system',   handler_family => q{Test},    handler_class  => q{Foo},  handler_action => q{*},    policy => 'GRANTED' );
set_System_access( type => 'system',   handler_family => q{Account}, handler_class  => q{List}, handler_action => q{*},    policy => 'DENIED' );

# Use case 3-a - Family Class Action - on system level
set_System_access( type => 'system',   handler_family => q{Core}, handler_class  => q{Empty}, handler_action => q{View},        policy => 'GRANTED' );
set_System_access( type => 'system',   handler_family => q{Core}, handler_class  => q{Empty}, handler_action => q{AddContent},  policy => 'DENIED' );



# Some user-level permissions
set_User_access( id => 4, handler_family => q{Core}, handler_class  => q{Empty}, handler_action => q{AddContent}, policy => 'GRANTED' );
set_User_access( id => 4, handler_family => q{User}, handler_class  => q{*},     handler_action => q{*},          policy => 'DENIED' );

my @tests = (
    {
        'name' => q{Permissions: guest},
        'url'  => q{/_Account/nataly/Permissions/},
    },
    {
        'name' => q{Permissions: authenticated},
        'url'  => q{/_Account/wanda/Permissions/},
    },
);

run_handler_tests(
    tests => \@tests,

    strip_dates => 1,

    skip_permissions => 1,
);

# vim: fdm=marker
