package SLight::Handler::Account::Account::Delete;
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

use SLight::API::User qw( delete_User get_User_by_login );
use SLight::DataStructure::Dialog::YesNo;
use SLight::Core::L10N qw( TR TF );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_Account_Delete');

    my $user_data = get_User_by_login($oid);

    $self->add_to_path_bar(
        label => TR('Accounts'),
        url   => {
            path   => [],
            action => 'View',
            step   => 'view',
        },
    );
    $self->add_to_path_bar(
        label => ( $user_data->{'name'} or $oid ),
        url   => {
            path   => [
                $oid,
                q{Account},
            ],
            action => 'View',
            step   => 'view',
        },
    );
    $self->add_to_path_bar(
        label => TR('Delete'),
        url   => {
            path   => [
                $oid,
                q{Account},
            ],
            action => 'Delete',
            step   => 'view',
        },
    );

    my $dialog = SLight::DataStructure::Dialog::YesNo->new(
        message => TF("Do you want to delete Account: '%s' (name: '%s')? Please confirm.", undef, $user_data->{'login'}, ( $user_data->{'name'} or q{-} )),

        yes_href => $self->build_url(
            action => 'Delete',
            step   => 'commit',
            path   => [
                $oid,
                q{Account},
            ],
        ),
        yes_caption => TR("Yes"),

        no_href => $self->build_url(
            action => 'Delete',
            step   => 'view',
            path   => [],
        ),
        no_caption => TR("No"),

        class => 'SL_Delete_Dialog',
    );

    $self->push_data($dialog);

    return;
} # }}}

sub handle_commit { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $user_data = get_User_by_login($oid);

    delete_User($user_data->{'id'});

    my $redirect_url = $self->build_url(
        path_handler => q{Account},
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
