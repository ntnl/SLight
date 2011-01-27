package SLight::Handler::Account::Permissions::Change;
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
use base q{SLight::Handler};

use SLight::API::Permissions qw( set_User_access clear_User_access );
use SLight::API::User qw( get_User_by_login );
# }}}

sub handle_grant { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $user_data = get_User_by_login($oid);

    set_User_access(
        id => $user_data->{'id'},

        handler_family => $self->{'options'}->{'h_family'},
        handler_class  => $self->{'options'}->{'h_class'},
        handler_action => $self->{'options'}->{'h_action'},

        policy => 'GRANTED',
    );

    return $self->_redirect($oid);
} # }}}

sub handle_deny { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $user_data = get_User_by_login($oid);

    set_User_access(
        id => $user_data->{'id'},

        handler_family => $self->{'options'}->{'h_family'},
        handler_class  => $self->{'options'}->{'h_class'},
        handler_action => $self->{'options'}->{'h_action'},

        policy => 'DENIED',
    );

    return $self->_redirect($oid);
} # }}}

sub handle_clear { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $user_data = get_User_by_login($oid);

    clear_User_access(
        id => $user_data->{'id'},

        handler_family => $self->{'options'}->{'h_family'},
        handler_class  => $self->{'options'}->{'h_class'},
        handler_action => $self->{'options'}->{'h_action'},

        _debug => 1,
    );

    return $self->_redirect($oid);
} # }}}

sub _redirect { # {{{
    my ( $self, $login ) = @_;

    $self->redirect(
        $self->build_url(
            path_handler => 'Account',
            path         => [ $login, q{Permissions} ],

            action => 'View',
            step   => 'view',
        ),
    );

    return;
} # }}}

# vim: fdm=marker
1;
