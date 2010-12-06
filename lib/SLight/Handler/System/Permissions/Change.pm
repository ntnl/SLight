package SLight::Handler::System::Permissions::Change;
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

use SLight::API::Permissions qw( set_System_access clear_System_access );
use SLight::Core::L10N qw( TR );
# }}}

sub handle_grant { # {{{
    my ( $self, $oid, $metadata ) = @_;

    set_System_access(
        type => $self->{'options'}->{'level'},

        handler_family => $self->{'options'}->{'h_family'},
        handler_class  => $self->{'options'}->{'h_class'},
        handler_action => $self->{'options'}->{'h_action'},

        policy => 'GRANTED',
    );

    return $self->_redirect();
} # }}}

sub handle_deny { # {{{
    my ( $self, $oid, $metadata ) = @_;

    set_System_access(
        type => $self->{'options'}->{'level'},

        handler_family => $self->{'options'}->{'h_family'},
        handler_class  => $self->{'options'}->{'h_class'},
        handler_action => $self->{'options'}->{'h_action'},

        policy => 'DENIED',
    );

    return $self->_redirect();
} # }}}

sub handle_clear { # {{{
    my ( $self, $oid, $metadata ) = @_;

    clear_System_access(
        type => $self->{'options'}->{'level'},

        handler_family => $self->{'options'}->{'h_family'},
        handler_class  => $self->{'options'}->{'h_class'},
        handler_action => $self->{'options'}->{'h_action'},

        _debug => 1,
    );

    return $self->_redirect();
} # }}}

sub _redirect { # {{{
    my ( $self ) = @_;

    $self->redirect(
        $self->build_url(
            path_handler => 'Permissions',
            path         => [ ],

            action => 'View',
            step   => $self->{'options'}->{'level'},
        ),
    );

    return;
} # }}}

# vim: fdm=marker
1;
