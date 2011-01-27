package SLight::Handler::User::Avatar::View;
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

use SLight::API::User qw( get_User_by_login );
use SLight::API::Avatar qw( get_Avatar );
use SLight::Core::L10N qw( TR );

use Gravatar::URL qw( gravatar_url );
use Carp::Assert::More qw( assert_defined );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $user_data = get_User_by_login($oid);

    assert_defined( $user_data );

    if ($user_data->{'avatar_Asset_id'}) {
        # On-site avatar used.
        my ( $data, $mime_type ) = get_Avatar($user_data->{'id'});

        $self->upload($data, $mime_type);
    }
    else {
        # Off-site avatar, supplied by Gravatar.
        $self->redirect(gravatar_url(email=>$user_data->{'email'}));
    }

    return;
} # }}}

# vim: fdm=marker
1;
