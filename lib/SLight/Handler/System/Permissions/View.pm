package SLight::Handler::System::Permissions::View;
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
use base q{SLight::HandlerBase::Permissions};

use SLight::API::Permissions qw( get_System_access );
use SLight::Core::L10N qw( TR TF );
use SLight::DataStructure::List;
use SLight::DataToken qw( mk_Link_token );
# }}}

# FIXME:
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

    $self->{'_level'} = 'system';

    $self->render_permissions({ level => 'system' });

    return;
} # }}}

sub handle_guest { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_System_Permissions');

    $self->{'_level'} = 'guest';

    $self->render_permissions({ level => 'guest' });

    return;
} # }}}

sub handle_authenticated { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_System_Permissions');

    $self->{'_level'} = 'authenticated';

    $self->render_permissions({ level => 'authenticated' });

    return;
} # }}}

sub get_inherited_policy { # {{{
    my ( $self, $family, $class, $action ) = @_;

    # Check 'system' settings, if the level is something above it.
    if ($self->{'_level'} ne 'system') {
        my $access_policy = get_System_access(
            type => q{system},

            handler_family => $family,
            handler_class  => $class,
            handler_action => $action,
        );

        return $access_policy;
    }

    return;
} # }}}

sub get_direct_policy { # {{{
    my ( $self, $family, $class, $action ) = @_;

    my $access_policy = get_System_access(
        type => $self->{'_level'},

        handler_family => $family,
        handler_class  => $class,
        handler_action => $action,
    );

    return $access_policy;
} # }}}

# vim: fdm=marker
1;
