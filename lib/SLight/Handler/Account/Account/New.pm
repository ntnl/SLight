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
use base q{SLight::HandlerBase::User::AccountForm};

use SLight::API::User qw( add_User );
use SLight::DataStructure::Form;
use SLight::Core::L10N qw( TR );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_Account_New');

    $self->_set_path_bar();

    $self->make_form(
        new_user => 1,
        admin    => 1,

        step   => 'save',
        data   => {},
        errors => {},

        form_label   => TR('New Account'),
        submit_label => TR('Add'),
    );

    return;
} # }}}

sub handle_save { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $errors = $self->validate_form(
        new_user => 1,
        admin    => 1,
    );

    if ($errors) {
        $self->set_class('SL_Account_New');

        $self->_set_path_bar();

        $self->make_form(
            new_user => 1,
            admin    => 1,

            step   => 'save',
            data   => {},
            errors => $errors,

            form_label   => TR('New Account'),
            submit_label => TR('Add'),
        );

        return;
    }

    add_User(
        login  => $self->{'options'}->{'u-login'},
        pass   => $self->{'options'}->{'u-pass'},
        name   => $self->{'options'}->{'u-name'},
        email  => $self->{'options'}->{'u-email'},
        status => $self->{'options'}->{'u-status'},
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

sub _set_path_bar { # {{{
    my ( $self ) = @_;

    $self->add_to_path_bar(
        label => TR('Accounts'),
        url   => {
            path   => [],
            action => 'View',
            step   => 'view',
        },
    );
    $self->add_to_path_bar(
        label => TR('New'),
        url   => {
            path   => [
                q{add},
                q{Account},
            ],
            action => 'New',
            step   => 'view',
        },
    );

    return;
} # }}}

# vim: fdm=marker
1;
