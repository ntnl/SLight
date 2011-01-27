package SLight::Handler::MyAccount::MyData::Edit;
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
use base q{SLight::HandlerBase::User::MyAccount};

use SLight::API::Email;
use SLight::API::EVK qw( add_EVK get_EVK_by_key delete_EVK );
use SLight::API::User qw( get_User update_User );
use SLight::Core::L10N qw( TR );
use SLight::Core::IO qw( unique_id );
use SLight::DataStructure::Form;
use SLight::DataStructure::Dialog::Notification;
use SLight::Validator qw( validate_input );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $user_data = ( $self->get_user_data() or return );

    $self->my_data_form($user_data, {});

    return;
} # }}}

sub handle_update { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_MyAccount_MyData');

    my $user_data = ( $self->get_user_data() or return );

    my $errors = validate_input(
        $self->{'options'},
        {
            email => { type => 'Email',  max_length => 256 },
            name  => { type => 'String', max_length => 64, optional => 1 },
        }
    );

    if ($errors) {
        return $self->my_data_form($user_data, $errors);
    }

    update_User(
        id => $user_data->{'id'},

        name => $self->{'options'}->{'name'},
    );

    my $redirect_url;
    if ($self->{'options'}->{'email'} and $self->{'options'}->{'email'} ne $user_data->{'email'}) {
        my $pass_key = unique_id();

        add_EVK(
            email => $self->{'options'}->{'email'},
            key   => $pass_key,

            metadata => {
                'made_by' => 'SLight::Handler::MyAccount::MyData::Edit',

                'user_id' => $user_data->{'id'},
                'login'   => $user_data->{'login'},

                'email' => $self->{'options'}->{'email'},
            }
        );

        # Send email to verify if the Account is working.
        my $verification_url = $self->build_url(
            path_handler => q{MyAccount},
            path         => [qw( MyAccount )],

            action  => q{Edit},
            step    => q{emailcheck},

            options => {
                email => $self->{'options'}->{'email'},
                key   => $pass_key,
            },
        );

        SLight::API::Email::send_confirmation(
            email             => $self->{'options'}->{'email'},
            name              => ( $self->{'options'}->{'name'} or $user_data->{'login'} ),
            confirmation_link => $verification_url,
        );

        # Redirect to page with after-email-change instructions.
        $redirect_url = $self->build_url(
            path_handler => q{MyAccount},
            path         => [qw( MyAccount )],

            action => q{Edit},
            step   => q{emailinfo},

            options => {},
        );
    }
    else {
        $redirect_url = $self->build_url(
            path_handler => q{MyAccount},
            path         => [],

            action => q{View},
            step   => q{view},

            options => {},
        );
    }

    $self->redirect($redirect_url);

    return;
} # }}}

sub handle_emailinfo { # {{{
    my ( $self, $oid, $metadata ) = @_;

    # Here, We just provide information.
    # Checking if User is logged-in, or not, would be nice, but not important.

    $self->set_class('SL_MyAccount_MyData');

    my $message = SLight::DataStructure::Dialog::Notification->new(
        text => TR("New email can be use only after it is verified: message has been sent to that address, with further information."),
    );

    $self->push_data($message);

    return;
} # }}}

sub handle_emailcheck { # {{{
    my ( $self, $oid, $metadata ) = @_;

    # Here, We just check email! User does not have to be logged-in!
    my $evk = get_EVK_by_key($self->{'options'}->{'key'});
    if (not $evk or $evk->{'metadata'}->{'email'} ne $self->{'options'}->{'email'}) {
        $self->set_class('SL_MyAccount_MyData');

        my $message = SLight::DataStructure::Dialog::Notification->new(
            text => TR("New email can be use only after it is verified: message has been sent to that address, with further information."),
        );

        $self->push_data($message);

        return;
    }

    my $user_data = get_User($evk->{'metadata'}->{'user_id'});

    update_User(
        id => $user_data->{'id'},

        email => $evk->{'metadata'}->{'email'},
    );

    delete_EVK($evk->{'id'});

    # Redirect to page with after-email-changed instructions.
    my $redirect_url = $self->build_url(
        path_handler => q{MyAccount},
        path         => [qw( MyAccount )],

        action  => q{Edit},
        step    => q{emailchanged},

        options => {},
    );
    $self->redirect($redirect_url);

    return;
} # }}}

sub handle_emailchanged { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_MyAccount_MyData');

    my $message = SLight::DataStructure::Dialog::Notification->new(
        text => TR("Email setting has been changed. All emails will be sent to new address."),
    );

    $self->push_data($message);

    return;
} # }}}




sub my_data_form { # {{{
    my ( $self, $user_data, $errors ) = @_;

    $self->set_class('SL_MyAccount_MyData');
    
    $self->add_to_path_bar(
        label => TR('My Account'),
        url   => {
            path   => [],
            action => 'View',
            step   => 'view',
        },
    );
    $self->add_to_path_bar(
        label => TR('Edit'),
        url   => {
            step   => 'view',
        },
    );

    my $action_url = $self->build_url(
        path_handler => q{MyAccount},
        path         => [qw( MyAccount )],

        action  => q{Edit},
        step    => q{update},

        options => {},
    );

    my $form = SLight::DataStructure::Form->new(
        class  => 'SL_MyAccount_MyData',
        action => $action_url,
        hidden => { },
        submit => TR('Update my data'),
    );

    $form->add_Entry(
        name    => q{name},
        caption => TR('Name') . q{:},
        value   => $user_data->{'name'},
        error   => $errors->{'name'},
    );
    $form->add_Entry(
        name    => q{email},
        caption => TR('Email') . q{:},
        value   => $user_data->{'email'},
        error   => $errors->{'email'},
    );

    $self->push_data($form);

    return;
} # }}}

# vim: fdm=marker
1;
