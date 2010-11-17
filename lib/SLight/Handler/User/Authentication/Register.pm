package SLight::Handler::User::Authentication::Register;
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
use base q{SLight::HandlerBase::User::AccountForm};

use SLight::API::User qw( add_User );
use SLight::DataStructure::Dialog::Notification;
use SLight::Core::L10N qw( TR TF );
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

    $self->push_data(
        $self->make_form(
            undef, # undef = new
            TR('Register User'),
            TR('Register'),
            {},
        ),
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
        0,
        $self->{'params'}->{'options'}
    );

    # Do We have any errors?
    if (scalar keys %{ $errors }) {
        # If so - show the form again, with errors, and data.
        $self->set_meta_field('title', TR(q{Register User - incorrect data}));

        $self->add_to_path_bar(
            label => TR('Register'),
            url   => {
            method  => 'GET',
                action  => 'register',
                options => {},
            },
        );

        # It will show the data User sent to us.
        $self->push_data(
            $self->make_form(
                undef, # undef = new
                TR('Register User'),
                TR('Register'),
                $errors,
            )
        );

        return;
    }

    add_User(
        login => $self->{'options'}->{'u-user'},

        name  => ( $self->{'options'}->{'u-name'} or q{} ),

        pass  => $self->{'options'}->{'u-pass'},
        email => $self->{'options'}->{'u-email'},

        status => 'Guest',
    );

    my $target_url = $self->build_url(
        path_handler => 'Authentication',
        path         => [],

        action  => 'register',
        step    => 'thankyou',
        options => {},
    );

    $self->redirect($target_url);

    return;
} # }}}

sub handle_thankyou { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $message = SLight::DataStructure::Dialog::Notification->new(
        text => TR("Thank You for registering! An email has been sent to You, with further information."),
    );

    $self->push_data($message);

    return;
} # }}}

# vim: fdm=marker
1;
