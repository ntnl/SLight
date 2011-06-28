package SLight::Handler::User::Authentication::Password;
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

use SLight::API::EVK qw( add_EVK delete_EVK get_EVK_by_key );
use SLight::API::User qw( get_User update_User get_Users_where );
use SLight::API::Email;
use SLight::Core::Config;
use SLight::Core::IO qw( unique_id );
use SLight::Core::L10N qw( TR TF );
use SLight::DataStructure::Dialog::Notification;
use SLight::DataStructure::Form;
use SLight::HandlerUtils::UserLogin;
use SLight::Validator qw( validate_input );
# }}}

sub handle_view { # {{{
    my ( $self ) = @_;

    my $form = $self->request_form({});

    $self->push_data($form);

    return;
} # }}}

sub handle_request { # {{{
    my ( $self, $oid, $metadata ) = @_;

    # User sent the initial request. Must send an email back to him...
    my $errors = validate_input(
        $self->{'options'},
        {
            login => { type=>'Login' },
            email => { type=>'Email' },
        }
    );

    my $user;
    if (not $errors) {
        # No lexical errors? OK, check if the User exists, and the user-email combination is OK...
        my $users = SLight::API::User::get_Users_where(
            login => $self->{'options'}->{'login'}
        );

        if ($users and $users->[0]) {
            $user = $users->[0];
        }

        if (not $user or $user->{'email'} ne $self->{'options'}->{'email'}) {
            $errors->{'login'} = TR('Login/email combination is not correct.');
        }
        elsif ($user->{'status'} eq 'Disabled') {
            $errors->{'login'} = TR('This Account is disabled.');
        }
    }

    if ($errors) {
        # Bad data, must show the same form again :(

        $self->request_form($errors);

        return;
    }

    # Email and pass typed OK, generate the key and send it to the poor User.
    my $pass_key = unique_id();

    add_EVK(
        email => $self->{'options'}->{'email'},
        key   => $pass_key,

        metadata => {
            'made_by' => 'SLight::Handler::User::Authentication::Password',
            'user_id' => $user->{'id'},
            'login'   => $user->{'login'},
        }
    );

    my $check_url = $self->build_url(
        path_handler => 'Authentication',
        path         => [],

        action  => 'Password',
        step    => 'entry',
        options => {
            login => $self->{'options'}->{'user'},
            key   => $pass_key,
        },

        add_domain => 1,
    );

    SLight::API::Email::send_notification(
        email         => $self->{'options'}->{'email'},
        name          => TR('User'),
        notifications => [
            TF("Password change request has been made, on %s. To reset the password, please follow the link: %s", undef, SLight::Core::Config::get_option('domain'), $check_url),
        ],
    );

    # Redirect to 'Requested!' page.
    my $target_url = $self->build_url(
        path_handler => 'Authentication',
        path         => [],

        action  => 'Password',
        step    => 'requested',
        options => {},

        add_domain => 1,
    );

    $self->redirect($target_url);

    return;
} # }}}

sub handle_requested { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_PasswordReset_Form');

    my $message = SLight::DataStructure::Dialog::Notification->new(
        text => TR("Password change has been requested. An email has been sent to You, with further information."),
    );

    $self->push_data($message);

    return;
} # }}}


sub handle_entry { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_PasswordReset_Form');

    # The 'key' proves that We are after the user got an email...

    my ( $target_user, $evk ) = $self->fetch_user_by_key();

    if ($target_user) {
        $self->password_form($target_user, {})
    }

    return;
} # }}}

sub handle_change { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_PasswordReset_Form');

#    $self->set_meta_field('title', TR(q{Password reset}));
#    
#    $self->add_to_path_bar(
#        label => TR('Password reset'),
#        url   => {
#        method  => 'GET',
#            action  => 'preset',
#            options => {},
#        },
#    );

    # The 'key' proves that We are after the user got an email...

    my ( $target_user, $evk ) = $self->fetch_user_by_key();

    # (see above)
    if ($target_user) {
        my $errors = validate_input(
            $self->{'options'},
            {
                pass => { type=>'Password', max_length => 128, extras=>{ 'pass-repeat'=>$self->{'options'}->{'pass-repeat'} } },
            }
        );

        if ($errors) {
            $self->password_form($target_user, $errors);

            return;
        }

        update_User(
            id   => $evk->{'metadata'}->{'user_id'},
            pass => $self->{'options'}->{'pass'},
        );

        delete_EVK($evk->{'id'});

        # Log-in the User and put him into his profile page.
        SLight::HandlerUtils::UserLogin::login($target_user->{'id'}, $target_user->{'login'});

        my $target_url = $self->build_url(
            path_handler => 'MyAccount',
            path         => [],

            action  => 'View',
            step    => 'view',
            options => {},

            add_domain => 1,
        );

        $self->redirect($target_url);
    }


    return;
} # }}}



sub request_form { # {{{
    my ( $self, $errors ) = @_;

    $self->set_class('SL_PasswordReset_Form');

    $self->set_meta_field('title', TR(q{Password recovery}));

    $self->add_to_path_bar(
        label => TR('Password recovery'),
        url   => {
            step => 'view',
        },
    );

    my $action_url = $self->build_url(
        path_handler => q{Authentication},
        path         => [],

        action  => q{Password},
        step    => q{request},

        options => {},
    );

    my $form = SLight::DataStructure::Form->new(
        class  => 'SL_Password_Reset',
        action => $action_url,
        hidden => { },
        submit => TR('Request password reset'),
    );
    $form->add_Entry(
        caption => TR('Login'),
        name    => 'login',
        value   => ( $self->{'options'}->{'login'} or q{} ),
        error   => $errors->{'login'},
    );
    $form->add_Entry(
        caption => TR('Email'),
        name    => 'email',
        value   => ( $self->{'options'}->{'email'} or q{} ),
        error   => $errors->{'email'},
    );


    return $form;
} # }}}

sub password_form { # {{{
    my ( $self, $user_data, $errors ) = @_;

    $self->set_class('SL_PasswordReset_Form');

    $self->set_meta_field('title', TR(q{Password recovery}));

    $self->add_to_path_bar(
        label => TR('Password recovery'),
        url   => {
            step    => 'entry',
            options => {
                key   => $self->{'options'}->{'key'},
                login => $self->{'options'}->{'login'},
            },
        },
    );

    my $action_url = $self->build_url(
        path_handler => q{Authentication},
        path         => [],

        action  => q{Password},
        step    => q{post},

        options => {},

        add_domain => 1,
    );

    my $form = SLight::DataStructure::Form->new(
        class  => 'SL_Password_Change',
        action => $action_url,
        hidden => {
            key   => $self->{'options'}->{'key'},
            login => $self->{'options'}->{'login'},
        },
        submit => TR('Change'),
    );
    $form->add_PasswordEntry(
        caption => TR('New password'),
        name    => 'pass',
        error   => $errors->{'pass'},
        value   => q{},
    );
    $form->add_PasswordEntry(
        caption => TR('New password (repeat)'),
        name    => 'pass-repeat',
        error   => $errors->{'pass-repeat'},
        value   => q{},
    );

    $self->push_data($form);

    return;
} # }}}

sub bad_user_error { # {{{
    my ( $self ) = @_;

    $self->set_meta_field('title', TR(q{Password recovery}));

    $self->add_to_path_bar(
        label => TR('Password recovery'),
        url   => {
            step => 'view',
        },
    );

    my $message = CoMe::Response::GenericMessage->new(
        text => TR("User can not be identified. Please verify."),
    );

    return $self->set_primary_content(
        $message->get_data()
    );
} # }}}

# Purpose:
#   Fetch EVK using it's key.
#   Fetch User's account, using metadata from EVK.
#   Check if EVK is OK and they match (set-up an error, if they do not).
sub fetch_user_by_key { # {{{
    my ( $self ) = @_;

    my $evk = get_EVK_by_key($self->{'options'}->{'key'});

    if (not $evk) {
        my $message = SLight::DataStructure::Dialog::Notification->new(
            text => TR("Verification Key is not correct. Please verify."),
        );

        $self->push_data($message);

        return;
    }

    my $user = get_User($evk->{'metadata'}->{'user_id'});

    if (not $user or $user->{'status'} eq 'Disabled') {
        my $message = SLight::DataStructure::Dialog::Notification->new(
            text => TR("User account does not exist, or is disabled. Password can not be changed."),
        );

        $self->push_data($message);

        return;
    }

    return ( $user, $evk );
} # }}}

# vim: fdm=marker
1;
