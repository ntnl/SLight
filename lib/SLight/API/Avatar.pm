package SLight::API::Avatar;
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
use base 'Exporter';

use SLight::API::User qw( get_User update_User );
use SLight::API::Asset qw( add_Asset get_Asset get_Asset_data delete_Asset );
# }}}

our @EXPORT_OK = qw(
    set_Avatar
    get_Avatar
    delete_Avatar
);
our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

# This is the first revision of the code! May qualify for refactoring!

sub get_Avatar { # {{{
    my ( $user_id ) = @_;

    my $user = get_User($user_id);

    if ($user->{'avatar_Asset_id'}) {
        my $data = get_Asset_data($user->{'avatar_Asset_id'});

        my $asset = get_Asset($user->{'avatar_Asset_id'});

        return ( $data, $asset->{'mime_type'} );
    }

    return ( undef, undef );
} # }}}

sub set_Avatar { # {{{
    my ( $user_id, $data ) = @_;

    my $user = get_User($user_id);

    my $asset_id = add_Asset(
        data     => $data,
        email    => $user->{'email'},
        filename => q{},
    );

    update_User(
        id              => $user->{'id'},
        avatar_Asset_id => $asset_id,
    );

    return $asset_id;
} # }}}

sub delete_Avatar { # {{{
    my ( $user_id ) = @_;

    my $user = get_User($user_id);

    if ($user->{'avatar_Asset_id'}) {
        update_User(
            id              => $user->{'id'},
            avatar_Asset_id => undef,
        );

        delete_Asset($user->{'avatar_Asset_id'});
    }

    return;
} # }}}

# vim: fdm=marker
1;
