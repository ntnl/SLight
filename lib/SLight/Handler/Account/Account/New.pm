package SLight::Handler::Account::Account::New;
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
use base q{SLight::HandlerBase::User::Account};

use SLight::API::User qw( add_User );
use SLight::DataStructure::Form;
use SLight::Core::L10N qw( TR );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_Account_New');

    $self->account_form(1, {}, {});

    return;
} # }}}

sub handle_save { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $errors = $self->validate_form(1);

    if ($errors) {
        $self->set_class('SL_Account_New');
    
        $self->account_form(
            1,
            $self->{'options'},
            $errors
        );

        return;
    }

    add_User(
        login  => $self->{'options'}->{'login'},
        pass   => $self->{'options'}->{'pass'},
        name   => $self->{'options'}->{'name'},
        email  => $self->{'options'}->{'email'},
        status => $self->{'options'}->{'status'},
    );

    my $redirect_url = $self->build_url(
        path_handler => q{Account},
        path         => [],

        action  => q{View},
        step    => q{view},

        options => {},
    );

    $self->redirect($redirect_url);

    return;
} # }}}

# vim: fdm=marker
1;
