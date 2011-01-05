package SLight::Handler::Account::Account::View;
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
use SLight::DataStructure::Properties;
use SLight::Core::L10N qw( TR );
# }}}

# FIXME:
# - add permissions overview
# - add avatar
# - add toolbox

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_Account_Data');

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

    my $my_data = SLight::DataStructure::Properties->new();

    $my_data->add_Property(
        caption => TR('Login') . q{:},
        value   => $user_data->{'login'},
    );
    $my_data->add_Property(
        caption => TR('Status') . q{:},
        value   => TR($user_data->{'status'}),
    );
    $my_data->add_Property(
        caption => TR('ID') . q{:},
        value   => $user_data->{'id'},
    );
    $my_data->add_Property(
        caption => TR('Name') . q{:},
        value   => $user_data->{'name'},
    );
    $my_data->add_Property(
        caption => TR('Email') . q{:},
        value   => $user_data->{'email'},
    );

    $self->push_data($my_data);

    return;
} # }}}

# vim: fdm=marker
1;
