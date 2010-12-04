package SLight::Handler::System::Permissions::View;
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
use base q{SLight::Handler};

use SLight::API::User;
use SLight::API::Permissions;
use SLight::DataStructure::List;
use SLight::DataStructure::List::Table;
use SLight::DataToken qw( mk_Link_token );
use SLight::Core::L10N qw( TR );
# }}}

# FIXME:
# - add permissions overview
# - add avatar
# - add toolbox
# - add path

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_System_Permissions');

    my $level_list = SLight::DataStructure::List->new(
        columns => [
            {
                caption => TR('Label'),
                name    => q{label},
            },
            {
                caption => TR('Description'),
                name    => q{desc},
            },
        ],
    );

    $level_list->add_Row(
        class => 'System',
        data  => {
            label => mk_Link_token(
                text => TR('System'),
                href => $self->build_url(
                    step => 'system',
                ),
            ),
            desc => TR('Policies applicable for both authenticated and non-authernticated Users.'),
        },
    );
    $level_list->add_Row(
        class => 'Guest',
        data  => {
            label => mk_Link_token(
                text => TR('Guest'),
                href => $self->build_url(
                    step => 'guest',
                ),
            ),
            desc => TR('Policies applicable for both non-authernticated Users.'),
        },
    );
    $level_list->add_Row(
        class => 'Authenticated',
        data  => {
            label => mk_Link_token(
                text => TR('Authenticated'),
                href => $self->build_url(
                    step => 'authenticated',
                ),
            ),
            desc => TR('Policies applicable for both authenticated Users.'),
        },
    );

    $self->push_data($level_list);

    return;
} # }}}

sub handle_system { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_System_Permissions');

    return;
} # }}}

sub handle_guest { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_System_Permissions');

    return;
} # }}}

sub handle_authenticated { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_System_Permissions');

    return;
} # }}}

sub _permissions { # {{{
    my ( $self, $level, @other_levels ) = @_;

    my $permissions = SLight::DataStructure::List::Table->new(
        columns => [
            {
                caption => TR('Module'),
                name    => q{module},
            },
            {
                caption => TR('Policy'),
                name    => q{policy},
            },
            {
                caption => TR('Notes'),
                name    => q{notes},
            },
            {
                caption => TR('Actions'),
                name    => q{actions},
            },
        ],
    );

    # ...

    $self->push_data($permissions);

    return;
} # }}}

# vim: fdm=marker
1;
