package SLight::Handler::Account::List::View;
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

use SLight::API::User qw( get_all_Users );
use SLight::Core::L10N qw( TR );
use SLight::DataStructure::List::Table;
use SLight::DataToken qw( mk_Link_token );
# }}}

sub handle_view { # {{{
    my ( $self ) = @_;

    $self->set_class('SL_AccountList');

    $self->add_to_path_bar(
        label => TR('Accounts'),
        url   => {
            path   => [],
            action => 'View',
            step   => 'view',
        },
    );

    my $table = SLight::DataStructure::List::Table->new(
        class   => 'SL_AccountList',
        columns => [
            {
                caption => TR(q{Login}),
                name    => 'login',
            },
            {
                caption => TR(q{Status}),
                name    => 'status',
            },
            {
                caption => TR(q{Name}),
                name    => 'name',
            },
            {
                caption => TR(q{}),
                name    => 'actions',
            },
        ],
    );

    my $users = get_all_Users();

    foreach my $user_data (sort { $a->{'login'} cmp $b->{'login'} } @{ $users }) {
        $table->add_Row(
            class => $user_data->{'status'},
            data  => {
                login   => [
                    mk_Link_token(
                        text => $user_data->{'login'},
                        href => $self->build_url(
                            path => [ $user_data->{'login'}, 'Account' ],
                        ),
                    ),
                ],
                status  => $user_data->{'status'},
                name    => ( $user_data->{'name'} or q{-} ),
                actions => [
                    $self->make_toolbox(
                        urls => [
                            {
                                action => 'Edit',
                                path   => [ $user_data->{'login'}, 'Account' ],
                            },
                            {
                                caption => TR('Avatar'),
                                class   => q{SL_Avatar_Action},
                                action  => 'View',
                                path   => [ $user_data->{'login'}, 'Avatar' ],
                            },
                            {
                                caption => TR('Permissions'),
                                class   => q{SL_Permissions_Action},
                                action  => 'View',
                                path    => [ $user_data->{'login'}, 'Permissions' ],
                            },
                            {
                                action => 'Delete',
                                path   => [ $user_data->{'login'}, 'Account' ],
                            },
                        ],
                    ),
                ]
            },
        );
    }

    $self->push_data($table);

    $self->set_toolbox(
        [
            {
                caption => TR('Add new Account'),
                action  => 'New',
                path    => [ 'add', 'Account' ],
            },
        ]
    );

    return;
} # }}}

# vim: fdm=marker
1;
