package SLight::Addon::User::Info;
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
use base q{SLight::Addon};

use SLight::API::User qw( get_User );
use SLight::Core::L10N qw( TR TF );
use SLight::DataToken qw( mk_Label_token mk_Link_token mk_Container_token );

# }}}

sub _process { # {{{
    my ( $self, %P ) = @_;

    my $message    = q{Not logged-in.};
    my $link_label = q{Login};

    my @content;
    if ($self->{'user'}->{'login'}) {
        my $user = get_User($self->{'user'}->{'id'});

        my $link_href = SLight::Core::URL::make_url(
            path_handler => 'Authentication',
            path         => [],

            action => 'Logout',

            lang => ( $self->{'lang'} or q{en} ),
        );

        push @content, mk_Link_token(
            href => SLight::Core::URL::make_url(
                path_handler => 'MyAccount',
                path         => [],
            ),
            text => TF(q{Logged-in as %s.}, undef, ( $user->{'name'} or $user->{'login'} )),
        );
        push @content, mk_Link_token(
            href => $link_href,
            text => TR(q{Logout}),
        );
    }
    else {
        my $link_href = SLight::Core::URL::make_url(
            path_handler => 'Authentication',
            path         => [],

            action => 'Login',

            lang => ( $self->{'lang'} or q{en} ),
        );
        
        push @content, mk_Label_token(
            text => TR(q{Not logged-in.}),
        );
        push @content, mk_Link_token(
            href => $link_href,
            text => TR(q{Login}),
        );
    }

    my $container = mk_Container_token(
        class   => 'SL_UserInfo_Addon',
        content => \@content,
    );

    return $container;
} # }}}

# vim: fdm=marker
1;
