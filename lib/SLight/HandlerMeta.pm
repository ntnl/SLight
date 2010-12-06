package SLight::HandlerMeta;
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
use base q{SLight::Core::Factory};

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

# Purpose:
#   Meta information related to Handlers.

sub get_handlers_list { # {{{
    return [
        {
            class => q{Account}, # {{{
            objects => [
                {
                    class => q{Account},
                    actions => [qw( Delete Edit New Password View )],
                },
                {
                    class => q{Avatar},
                    actions => [qw( Change Delete Image View )],
                },
                {
                    class => q{List},
                    actions => [qw( View )],
                },
                {
                    class => q{Permissions},
                    actions => [qw( Change View )],
                },
            ], # }}}
        },
        {
            class => q{CMS}, # {{{
            objects => [
                {
                    class => q{Entry},
                    actions => [qw( AddContent Delete Edit View )],
                },
                {
                    class => q{Spec},
                    actions => [qw( Delete Edit New View )],
                },
                {
                    class => q{SpecField},
                    actions => [qw( Delete Edit New View )],
                },
                {
                    class => q{SpecList},
                    actions => [qw( View )],
                },
                {
                    class => q{Welcome},
                    actions => [qw( AddContent View )],
                }
            ], # }}}
        },
        {
            class => q{Core}, # {{{
            objects => [
                {
                    class => 'Asset',
                    actions => [qw( Delete Download Thumb View )],
                },
                {
                    class => 'AssetList',
                    actions => [qw( View )],
                },
                {
                    class => 'Empty',
                    actions => [qw( AddContent Delete View )],
                },
            ], # }}}
        },
        {
            class => q{MyAccount}, # {{{
            objects => [
                {
                    class => 'Avatar',
                    actions => [qw( Change Delete View )],
                },
                {
                    class => 'MyData',
                    actions => [qw( Edit Password View )],
                },
                {
                    class => 'Password',
                    actions => [qw( View )],
                }
            ], # }}}
        },
        {
            class => q{System}, # {{{
            objects => [
                {
                    class => 'Permissions',
                    actions => [qw( View Change )],
                },
            ], # }}}
        },
        {
            class => q{Test}, # {{{
            objects => [
                {
                    class => 'Foo',
                    actions => [qw( View )],
                }
            ], # }}}
        },
        {
            class => q{User}, # {{{
            objects => [
                {
                    class => 'Authentication',
                    actions => [qw( ActivateAccount Login Logout Password Register )],
                },
            ], # }}}
        },
    ];
} # }}}

# vim: fdm=marker
1;
