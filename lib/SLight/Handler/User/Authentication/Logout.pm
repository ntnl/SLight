package SLight::Handler::User::Authentication::Logout;
################################################################################
# 
# SLight - Lightweight Content Manager System.
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

# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    SLight::Core::Session::part_set(
        'user',
        {}
    );
    SLight::Core::Session::save();

    # FIXME: User should be redirected to the page, where He used the 'Logout'.

    $self->redirect(
        $self->build_url(
            path_handler => 'Page',
            path         => [],

            action => 'View',
            step   => 'view'
        ),
    );

    return;
} # }}}

# vim: fdm=marker
1;
