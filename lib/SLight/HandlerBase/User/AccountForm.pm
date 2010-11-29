package SLight::HandlerBase::User::AccountForm;
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

use SLight::DataStructure::Form;
use SLight::Core::L10N qw( TR TF );
use SLight::Validator qw( validate_input );

use Params::Validate qw( :all );
# }}}

# Returns form, that (probably) should be put into main content of the page.
# Parameters:
#   $edit
#       If $edit is set, it should be a hashref with current data.
#       If it is undef, then we are doing addition.
#
#   $form_label
#       String used as a form's label.
#
#   $submit_label
#       String used as a label for Submit key.
#
#   $errors
#       Hashref.
sub make_form { # {{{
    my ( $self, $edit, $form_label, $submit_label, $errors ) = @_;

    my $form = SLight::DataStructure::Form->new(
        action => $self->build_url(
            method  => 'POST',
            options => {},
        ),
        hidden  => {},
        submit  => $submit_label,
    );
    # Add the caption, so User knows what kind of data it enters.
    $form->add_Label(
        text => $form_label,
    );
    # In edit mode we already have the login, and it generally should not change.
    if (not $edit) {
        $form->add_Entry(
            caption => TR('Login'),
            name    => 'u-user',
            value   => ( $self->{'options'}->{'u-user'} or q{} ),
            error   => ( $errors->{'user'} or q{} ),
        );

        # Reset to an empty hash (otherwise it may be undef, zero or empty string).
        $edit = {};
    }

    # All other options are common to both Add and Edit modes.
    $form->add_Entry(
        caption => TR('Email'),
        name    => 'u-email',
        value   => ( $self->{'options'}->{'u-email'} or $edit->{'email'} or q{} ),
        error   => ( $errors->{'email'} or q{} ),
    );
    $form->add_Entry(
        caption => TR('Name'),
        name    => 'u-name',
        value   => ( $self->{'options'}->{'u-name'} or $edit->{'name'} or q{} ),
        error   => ( $errors->{'name'} or q{} ),
    );
    $form->add_PasswordEntry(
        caption => TR('Password'),
        name    => 'u-pass',
        value   => q{}, # Always empty, putting password here could lead to vulnerability!
        error   => ( $errors->{'pass'} or q{} ),
    );
    $form->add_PasswordEntry(
        caption => TR('Password (repeat)'),
        name    => 'u-pass-repeat',
        value   => q{}, # Always empty, putting password here could lead to vulnerability!
    );

    return $form;
} # }}}

# Validate User Data form input.
# Returns errors (hash ref), or empty hash ref
sub validate_form { # {{{
    my ( $self, $edit, $options ) = @_;

    my %given_data = (
        email => $options->{'u-email'},
        name  => $options->{'u-name'},
        pass  => $options->{'u-pass'}
    );
    my %meta_data = (
        email => { type => 'Email',  max_length => 256 },
        name  => { type => 'String', max_length => 64, optional => 1 },
        pass  => {
            type       => 'Password',
            max_length => 64,

            extras => {
                'pass-repeat' => $options->{'u-pass-repeat'}
            }
        }
    );

    # In Edit mode login is passed trough 'system' ways.
    # Otherwise, it is a direct User input, and should be validated at form level.
    if (not $edit) {
        $given_data{'user'} = $options->{'u-user'};

        $meta_data{'user'} = {
            type       => 'Login',
            max_length => 64
        };
    }

#    use Data::Dumper; warn Dumper \%errors;

    return validate_input(\%given_data, \%meta_data);
} # }}}

# vim: fdm=marker
1;
