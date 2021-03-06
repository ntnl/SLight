package SLight::Handler::User::Authentication::Register;
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
use base q{SLight::HandlerBase::User::AccountForm};

use SLight::API::Email;
use SLight::API::EVK qw( add_EVK );
use SLight::API::User qw( add_User );
use SLight::Core::Config;
use SLight::Core::IO qw( unique_id );
use SLight::Core::L10N qw( TR TF );
use SLight::DataStructure::Dialog::Notification;
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_Register_User');

    $self->set_meta_field('title', TR(q{Register User}));

    $self->add_to_path_bar(
        label => TR('Register'),
        url   => {
            path_handler => 'Authentication',
            path         => [],

            action  => 'Register',
            options => {},
        },
    );

    $self->make_form(
        new_user => 1,

        step         => 'request',
        form_label   => TR('Register User'),
        submit_label => TR('Register'),

        errors => {},
    );

    return;
} # }}}

sub handle_request { # {{{
    my ( $self, $oid, $metadata ) = @_;

#    my $now = time;
#
#    if ($ENV{'NOW_TIMESTAMP'}) {
#        $now = $ENV{'NOW_TIMESTAMP'};
#    }

    my $errors = $self->validate_form(
        new_user => 1,
    );

    # Do We have any errors?
    if (scalar keys %{ $errors }) {
        # If so - show the form again, with errors, and data.
        $self->set_meta_field('title', TR(q{Register User - incorrect data}));

        $self->set_class('SL_Register_User');

        $self->add_to_path_bar(
            label => TR('Register'),
            url   => {
                path_handler => 'Authentication',
                path         => [],

                step    => 'view',
                action  => 'Register',
                options => {},
            },
        );

        # It will show the data User sent to us.
        $self->make_form(
            new_user => 1,

            step         => 'request',
            form_label   => TR('Register User'),
            submit_label => TR('Register'),

            errors => $errors,
        );

        return;
    }

    # Create a 'Guest' User account, that someone must verify.
    my $id = add_User(
        login => $self->{'options'}->{'u-login'},

        name  => ( $self->{'options'}->{'u-name'} or q{} ),

        pass  => $self->{'options'}->{'u-pass'},
        email => $self->{'options'}->{'u-email'},

        status => 'Guest',
    );

    # Send the notification...
    my $activation_key = unique_id();

    add_EVK(
        email => $self->{'options'}->{'u-email'},
        key   => $activation_key,

        metadata => {
            'made_by' => 'SLight::Handler::User::Authentication::Register',
            'user_id' => $id,
            'login'   => $self->{'options'}->{'u-login'},
        }
    );

    my $activate_url = $self->build_url(
        path_handler => 'Authentication',
        path         => [],

        action  => 'ActivateAccount',
        step    => 'view',
        options => {
            login => $self->{'options'}->{'u-login'},
            key   => $activation_key,
        },

        add_domain => 1,
    );

    SLight::API::Email::send_registration(
        email             => $self->{'options'}->{'u-email'},
        domain            => SLight::Core::Config::get_option('domain'),
        name              => ( $self->{'options'}->{'u-name'} or $self->{'options'}->{'u-login'} ),
        confirmation_link => $activate_url,
    );

    my $mailback = SLight::Core::Config::get_option('mailback');
    warn $mailback;
    if ($mailback) {
        SLight::API::Email::send_notification(
            email => $mailback,
            name  => 'Webmaster',

            notifications => [
                q{New User account registered: } . $self->{'options'}->{'u-login'} .q{ using email: } . $self->{'options'}->{'u-email'},
            ]
        );
    }

    # Redirect to 'Thank you' page.
    my $target_url = $self->build_url(
        path_handler => 'Authentication',
        path         => [],

        action  => 'Register',
        step    => 'thankyou',
        options => {},
    );

    $self->redirect($target_url);

    return;
} # }}}

sub handle_thankyou { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_Register_User');

    $self->add_to_path_bar(
        label => TR('Register'),
        url   => {
            path_handler => 'Authentication',
            path         => [],

            step    => 'view',
            action  => 'Register',
            options => {},
        },
    );

    my $message = SLight::DataStructure::Dialog::Notification->new(
        text => TR("Thank You for registering! An email has been sent to You, with further information."),
    );

    $self->push_data($message);

    return;
} # }}}

# vim: fdm=marker
1;
