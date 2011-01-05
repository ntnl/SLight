package SLight::Handler::Account::Account::Edit;
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

use SLight::API::User qw( update_User get_User_by_login );
use SLight::Core::L10N qw( TR TF );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_Account_Edit');

    my $user_data = get_User_by_login($oid);
    
    $self->_set_path_bar($user_data);

    $self->make_form(
        new_user => 0,
        admin    => 1,

        step   => 'save',
        data   => $user_data,
        errors => {},

        form_label   => TF('Edit Account: %s', undef, $oid),
        submit_label => TR('Update'),
    );

    return;
} # }}}

sub handle_save { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $user_data = get_User_by_login($oid);

    my $errors = $self->validate_form(
        admin => 1,
    );

    if ($errors) {
        $self->set_class('SL_Account_Edit');

        $self->_set_path_bar($user_data);

        $self->make_form(
            new_user => 0,
            admin    => 1,

            step   => 'save',
            data   => {},
            errors => $errors,

            form_label   => TF('Edit Account: %s', undef, $oid),
            submit_label => TR('Update'),
        );

        return;
    }

    update_User(
        id => $user_data->{'id'},

        name   => $self->{'options'}->{'u-name'},
        email  => $self->{'options'}->{'u-email'},
        status => $self->{'options'}->{'u-status'},

#        _debug => 1,
    );

    my $redirect_url = $self->build_url(
        path_handler => q{Account},
        path         => [ $oid, q{Account} ],

        action  => q{View},
        step    => q{view},

        options => {},
    );

    $self->redirect($redirect_url);

    return;
} # }}}

sub _set_path_bar { # {{{
    my ( $self, $user_data ) = @_;

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
        label => TR('Edit'),
        url   => {
            path   => [
                $user_data->{'login'},
                q{Account},
            ],
            action => 'Edit',
            step   => 'view',
        },
    );

    return;
} # }}}

# vim: fdm=marker
1;
