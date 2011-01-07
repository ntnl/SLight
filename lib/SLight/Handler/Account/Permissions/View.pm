package SLight::Handler::Account::Permissions::View;
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
use base q{SLight::HandlerBase::Permissions};

use SLight::API::Permissions qw( get_System_access get_User_access );
use SLight::Core::L10N qw( TR TF );
use SLight::API::User qw( get_User_by_login );
# }}}

# FIXME:
# - add path

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_Account_Permissions');

    my $user_data = get_User_by_login($oid);

    $self->add_to_path_bar(
        label => TR('Accounts'),
        url   => {
            path   => [],
            action => 'View',
            step   => 'view',
        },
    );
    $self->add_to_path_bar(
        label => ( $user_data->{'name'} or $user_data->{'login'} ),
        url   => {
            path   => [
                $user_data->{'login'},
                q{Account},
            ],
            action => 'View',
            step   => 'view',
        },
    );
    $self->add_to_path_bar(
        label => TR('Permissions'),
        url   => {
            path   => [
                $user_data->{'login'},
                q{Permissions},
            ],
            action => 'View',
            step   => 'view',
        },
    );

    $self->{'_uid'} = $user_data->{'id'};

    $self->render_permissions( {} );

    return;
} # }}}

sub get_inherited_policy { # {{{
    my ( $self, $family, $class, $action ) = @_;

    # Check 'system' settings, if the level is something above it.
    my $access_policy = get_System_access(
        type => q{system},

        handler_family => $family,
        handler_class  => $class,
        handler_action => $action,
    );

    if ($access_policy) {
        return $access_policy;
    }

    return get_System_access(
        type => q{authenticated},

        handler_family => $family,
        handler_class  => $class,
        handler_action => $action,
    );
} # }}}

sub get_direct_policy { # {{{
    my ( $self, $family, $class, $action ) = @_;

    my $access_policy = get_User_access(
        id => $self->{'_uid'},

        handler_family => $family,
        handler_class  => $class,
        handler_action => $action,
    );

    return $access_policy;
} # }}}

# vim: fdm=marker
1;
