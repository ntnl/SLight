package SLight::Addon::User::Info;
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
use base q{SLight::Addon};

use SLight::API::User qw( get_User );
use SLight::Core::L10N qw( TR TF );
use SLight::DataToken qw( mk_Label_token mk_Link_token mk_Container_token );

# }}}

sub _process { # {{{
    my ( $self, %P ) = @_;

    my $message    = q{Not logged-in.};
    my $link_label = q{Login};
    my $link_href  = q{};

    if ($self->{'user'}->{'login'}) {
        my $user = get_User($self->{'user'}->{'id'});

        $message    = TF(q{Logged-in as %s.}, undef, ( $user->{'name'} or $user->{'login'} ) );
        $link_label = q{Logout};

        $link_href = SLight::Core::URL::make_url(
            path_handler => 'Authentication',
            path         => [],

            action => 'Logout',

            lang => ( $self->{'lang'} or q{en} ),
        );
    }
    else {
        $link_href = SLight::Core::URL::make_url(
            path_handler => 'Authentication',
            path         => [],

            action => 'Login',

            lang => ( $self->{'lang'} or q{en} ),
        );
    }

    my $container = mk_Container_token(
        class   => 'SL_UserInfo_Addon',
        content => [
            mk_Label_token(
                text => $message,
            ),
            mk_Link_token(
                href  => $link_href,
                text => $link_label,
            ),
        ],
    );

    return $container;
} # }}}

# vim: fdm=marker
1;
