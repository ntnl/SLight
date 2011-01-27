package SLight::Handler::MyAccount::Avatar::Change;
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

use SLight::API::Avatar qw( set_Avatar );
use SLight::Core::L10N qw( TR );
use SLight::DataStructure::Form;
use SLight::Validator qw( validate_input );
# }}}

# FIXME:
#   This module's code is a louse copy from SLight::Handler::Account::Avatar::Change
#   Refactor for next release, to improve code sharing.

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $user_data = ( $self->get_user_data() or return );

    return $self->_form({});
} # }}}

sub handle_save { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $user_data = ( $self->get_user_data() or return );

    my %validator_metadata = (
        avatar => {
            type       => 'Any',
            optional   => 0,
            max_length => 1024 * 25, # Max 20KB
        },
    );

    my $errors = validate_input($self->{'options'}, \%validator_metadata);

    if ($errors) {
        return $self->_form($errors);
    }

    set_Avatar(
        $user_data->{'id'},
        $self->{'options'}->{'avatar'},
    );

    my $redirect_url = $self->build_url(
        path_handler => q{MyAccount},
        path         => [ q{Avatar} ],

        action  => q{View},
        step    => q{view},

        options => {},
    );

    $self->redirect($redirect_url);

    return;
} # }}}

sub _form { # {{{
    my ( $self, $errors ) = @_;

    $self->set_class('SL_MyAccount_Avatar');
    
    $self->add_to_path_bar(
        label => TR('My Account'),
        url   => {
            path   => [],
            action => 'View',
            step   => 'view',
        },
    );
    $self->add_to_path_bar(
        label => TR('Avatar'),
        url   => {
            action => 'View',
            step   => 'view',
        },
    );
    $self->add_to_path_bar(
        label => TR('Change'),
        url   => {
            step => 'view',
        },
    );

    my $form = SLight::DataStructure::Form->new(
        submit => TR('Upload'),
        action => $self->build_url(
            step => 'save',
        ),
        hidden => {
        }
    );

    $form->add_FileEntry(
        name => q{avatar},

        caption => TR('Avatar image'),
        error   => $errors->{ q{avatar} },
    );

    $self->push_data($form);

    return;
} # }}}


# vim: fdm=marker
1;
