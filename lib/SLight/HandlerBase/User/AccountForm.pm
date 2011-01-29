package SLight::HandlerBase::User::AccountForm;
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

use SLight::DataStructure::Form;
use SLight::Core::L10N qw( TR TF );
use SLight::Validator qw( validate_input );

use Params::Validate qw( :all );
# }}}

# Returns form, that (probably) should be put into main content of the page.
# Parameters:
#   
#   new_user
#       Forces 'Login', 'Password', 'Password (repeat)'
#
#   admin
#       Forces 'Password', 'Password (repeat)' and 'Status'
#
#   data
#       Data used to initialize the form (if there is not data in 'options')
#
#   form_label
#       String used as a form's label.
#
#   submit_label
#       String used as a label for Submit key.
#
#   errors
#       Hashref.
#
#   step
#
sub make_form { # {{{
    my ( $self, %P ) = @_;

    my $form = SLight::DataStructure::Form->new(
        action => $self->build_url(
            method  => 'POST',
            options => {},
            step    => $P{'step'},
        ),
        hidden  => {},
        submit  => $P{'submit_label'},
    );
    # Add the caption, so User knows what kind of data it enters.
    $form->add_Label(
        text => $P{'form_label'},
    );

    # In edit mode we already have the login, and it generally should not change.
    if ($P{'new_user'}) {
        $form->add_Entry(
            caption => TR('Login:'),
            name    => 'u-login',
            value   => ( $self->{'options'}->{'u-login'} or q{} ),
            error   => ( $P{'errors'}->{'login'} or q{} ),
        );

        # Reset to an empty hash (otherwise it may be undef, zero or empty string).
        $P{'data'} = {};

        $form->add_PasswordEntry(
            caption => TR('Password:'),
            name    => 'u-pass',
            value   => q{}, # Always empty, putting password here could lead to vulnerability!
            error   => $P{'errors'}->{'pass'},
        );
        $form->add_PasswordEntry(
            caption => TR('Password (repeat):'),
            name    => 'u-pass-repeat',
            value   => q{},
            error   => q{},
        );
    }
    if ($P{'admin'}) {
        $form->add_SelectEntry(
            caption => TR('Status:'),
            name    => 'u-status',
            value   => ( $self->{'options'}->{'u-status'} or $P{'data'}->{'status'} or q{} ),
            options => [
                [
                    q{Disabled},
                    TR('Disabled'),
                ],
                [
                    q{Guest},
                    TR('Guest'),
                ],
                [
                    q{Enabled},
                    TR('Enabled'),
                ],
            ],
            error => $P{'errors'}->{'status'},
        );
    }

    # All other options are common.
    $form->add_Entry(
        caption => TR('Name:'),
        name    => 'u-name',
        value   => ( $self->{'options'}->{'u-name'} or $P{'data'}->{'name'} or q{} ),
        error   => ( $P{'errors'}->{'name'} or q{} ),
    );
    $form->add_Entry(
        caption => TR('Email:'),
        name    => 'u-email',
        value   => ( $self->{'options'}->{'u-email'} or $P{'data'}->{'email'} or q{} ),
        error   => ( $P{'errors'}->{'email'} or q{} ),
    );

    $self->push_data($form);

    return;
} # }}}

# Validate User Data form input.
# Returns errors (hash ref), or empty hash ref
# Parameters:
#   admin
#
#   new_user
#
sub validate_form { # {{{
    my ( $self, %P ) = @_;

    my %given_data = (
        email => $self->{'options'}->{'u-email'},
        name  => $self->{'options'}->{'u-name'},
    );
    my %meta_data = (
        email => { type => 'Email',  max_length => 256 },
        name  => { type => 'String', max_length => 64, optional => 1 },
    );
    if ($P{'new_user'}) {
        $given_data{'pass'} = $self->{'options'}->{'u-pass'};

        $meta_data{'pass'} = {
            type       => 'Password',
            max_length => 64,

            extras => {
                'pass-repeat' => $self->{'options'}->{'u-pass-repeat'}
            }
        };
        $given_data{'login'} = $self->{'options'}->{'u-login'};

        $meta_data{'login'} = {
            type       => 'Login',
            max_length => 64
        };
    }

#    use Data::Dumper; warn Dumper \%errors;

    return validate_input(\%given_data, \%meta_data);
} # }}}

# vim: fdm=marker
1;
