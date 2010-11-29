package SLight::Handler::MyAccount::Password::View;
################################################################################
# 
# SLight - Lightweight Content Manager System.
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
use base qw(
    SLight::HandlerBase::User::MyAccount
    SLight::HandlerBase::User::PasswordForm
);

use SLight::API::User qw( update_User get_User_by_login );
use SLight::Core::L10N qw( TR );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_MyAccount_Password');

    my $user_data = ( $self->get_user_data() or return );

    $self->password_form(0, $user_data, {});

    return;
} # }}}

sub handle_save { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $user_data = ( $self->get_user_data() or return );

    my $errors = $self->validate_form(0);

    if ($errors) {
        $self->set_class('SL_MyAccount_Password');

        $self->password_form(
            0,
            $errors
        );

        return;
    }

    update_User(
        id => $user_data->{'id'},

        pass => $self->{'options'}->{'pass'},

#        _debug => 1,
    );

    my $redirect_url = $self->build_url(
        path_handler => q{MyAccount},
        path         => [],

        action => q{View},
        step   => q{view},

        options => {},
    );

    $self->redirect($redirect_url);

    return;
} # }}}

# vim: fdm=marker
1;
