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

use SLight::Test::Site;
use SLight::Test::Handler qw( run_handler_tests );
use SLight::API::Permissions qw( set_System_access set_User_access );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
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
);

# vim: fdm=marker
