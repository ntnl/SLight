package SLight::Handler::MyAccount::Avatar::View;
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

use SLight::API::Avatar qw( get_Avatar );
use SLight::DataStructure::Token;
use SLight::DataToken qw( mk_Container_token mk_Label_token mk_Image_token mk_Link_token );
use SLight::Core::L10N qw( TR );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_MyAccount_Avatar');

    $self->add_to_path_bar(
        label => TR('My Account'),
        url   => {
            path   => [],
            step => 'view',
        },
    );
    $self->add_to_path_bar(
        label => TR('Avatar'),
        url   => {
            step => 'view',
        },
    );

    my $user_data = ( $self->get_user_data() or return );

    # FIXME:
    #   Stuff bellow is a copy from SLight::Handler::Account::Avatar::View
    #   Refactor for next release, to improve code sharing.

    my @stuff;

    push @stuff, mk_Image_token(
        class => q{SL_Avatar},
        href  => $self->build_url(
            path_handler => q{Avatar},
            path         => [ $user_data->{'login'} ],
        ),
        label => 'Avatar',
    );

    if ($user_data->{'avatar_Asset_id'}) {
        # This user has an avatar hosted by the site.
        push @stuff, mk_Label_token(
            text => TR("Avatar is hosted on site."),
        );
        
        push @stuff, mk_Link_token(
            text => TR('Upload Avatar'),
            href => $self->build_url(
                action => 'Change',
            ),
        );
        push @stuff, mk_Link_token(
            text => TR('Delete Avatar'),
            href => $self->build_url(
                action => 'Delete',
            ),
        );
    }
    else {
        # This User does not have an avatar.
        push @stuff, mk_Label_token(
            text => TR("Avatar image was not uploaded, Gravatar image will be used instead."),
        );
        
        push @stuff, mk_Link_token(
            text => TR('Upload Avatar'),
            href => $self->build_url(
                action => 'Change',
            ),
        );
    }

    my $token_ds = SLight::DataStructure::Token->new(
        token => mk_Container_token(
            content => \@stuff,
        ),
    );

    $self->push_data($token_ds);

    return;
} # }}}


# vim: fdm=marker
1;
