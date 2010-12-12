package SLight::Handler::Account::Avatar::Delete;
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

use SLight::Core::L10N qw( TR TF );
use SLight::DataStructure::Dialog::YesNo;
use SLight::API::User qw( get_User_by_login );
use SLight::API::Avatar qw( delete_Avatar );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_Account_Avatar');

    my $user_data = get_User_by_login($oid);

    my $dialog = SLight::DataStructure::Dialog::YesNo->new(
        message => TF("Do you want to delete avatar for Account: '%s'? Please confirm.", undef, $user_data->{'login'}),

        yes_href => $self->build_url(
            action => 'Delete',
            step   => 'commit',
            path   => [
                $oid,
                q{Avatar},
            ],
        ),
        yes_caption => TR("Yes"),

        no_href => $self->build_url(
            action => 'View',
            step   => 'view',
            path   => [
                $oid,
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

    my $user_data = get_User_by_login($oid);

    delete_Avatar($user_data->{'id'});

    my $redirect_url = $self->build_url(
        path_handler => q{Account},
        path         => [
            $oid,
            q{Avatar},
        ],

        action  => q{View},
        step    => q{view},

        options => {},
    );

    $self->redirect($redirect_url);

    return;
} # }}}

# vim: fdm=marker
1;
