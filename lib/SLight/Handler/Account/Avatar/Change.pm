package SLight::Handler::Account::Avatar::Change;
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

use SLight::API::User qw( get_User_by_login );
use SLight::API::Avatar qw( set_Avatar );
use SLight::Core::L10N qw( TR );
use SLight::DataStructure::Form;
use SLight::Validator qw( validate_input );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $user_data = get_User_by_login($oid);

    return $self->_form($user_data, {});
} # }}}

sub handle_save { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $user_data = get_User_by_login($oid);

    my %validator_metadata = (
        avatar => {
            type       => 'Any',
            optional   => 0,
            max_length => 1024 * 25, # Max 20KB
        },
    );

    my $errors = validate_input($self->{'options'}, \%validator_metadata);

    if ($errors) {
        return $self->_form($user_data, $errors);
    }

    set_Avatar(
        $user_data->{'id'},
        $self->{'options'}->{'avatar'},
    );

    my $redirect_url = $self->build_url(
        path_handler => q{Account},
        path         => [ $oid, q{Avatar} ],

        action  => q{View},
        step    => q{view},

        options => {},
    );

    $self->redirect($redirect_url);

    return;
} # }}}

sub _form { # {{{
    my ( $self, $user_data, $errors ) = @_;

    $self->set_class('SL_Account_Avatar');

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
        label => TR('Avatar'),
        url   => {
            path   => [
                $user_data->{'login'},
                q{Avatar},
            ],
            action => 'View',
            step   => 'view',
        },
    );
    $self->add_to_path_bar(
        label => TR('Change'),
        url   => {
            path   => [
                $user_data->{'login'},
                q{Avatar},
            ],
            action => 'Change',
            step   => 'view',
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
