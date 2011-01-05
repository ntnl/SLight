package SLight::Handler::MyAccount::Avatar::Delete;
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
use base q{SLight::HandlerBase::User::MyAccount};

use SLight::Core::L10N qw( TR TF );
use SLight::DataStructure::Dialog::YesNo;
use SLight::API::Avatar qw( delete_Avatar );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

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
        label => TR('Delete'),
        url   => {
            step => 'view',
        },
    );

    my $user_data = ( $self->get_user_data() or return );

    my $dialog = SLight::DataStructure::Dialog::YesNo->new(
        message => TR("Do you want to delete avatar hosted on the site? Please confirm."),

        yes_href => $self->build_url(
            step   => 'commit',
            path   => [
                q{Avatar},
            ],
        ),
        yes_caption => TR("Yes"),

        no_href => $self->build_url(
            action => 'View',
            step   => 'view',
            path   => [
                q{Avatar},
            ],
        ),
        no_caption => TR("No"),

        class => 'SL_Delete_Dialog',
    );

    $self->push_data($dialog);

    return;
} # }}}

sub handle_commit { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $user_data = ( $self->get_user_data() or return );

    delete_Avatar($user_data->{'id'});

    my $redirect_url = $self->build_url(
        path_handler => q{MyAccount},
        path         => [ ],

        action  => q{View},
        step    => q{view},

        options => {},
    );

    $self->redirect($redirect_url);

    return;
} # }}}

# vim: fdm=marker
1;
