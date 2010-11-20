package SLight::HandlerBase::User::MyAccount;
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

sub get_user_data { # {{{
    my ( $self ) = @_;

    if ($self->{'user'}->{'id'}) {
        my $user = get_User($self->{'user'}->{'id'});


        # FIXME! Check status!

        return $user;
    }

    # Return AccessDenied error!

    return;
} # }}}

# vim: fdm=marker
1;
