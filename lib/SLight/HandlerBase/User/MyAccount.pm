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

use SLight::API::User qw( get_User );
# }}}

sub get_user_data { # {{{
    my ( $self ) = @_;

#    use Data::Dumper; warn "User in handler: ". Dumper $self->{'user'};

    if ($self->{'user'}->{'id'}) {
        my $user = get_User($self->{'user'}->{'id'});

        if ($user->{'status'} eq 'Disabled') {
            # FIXME: Throw a 'Account disabled' warning here!
            return;
        }

        return $user;
    }

    # Return AccessDenied error, bu doing internal redirect!

    return;
} # }}}

# vim: fdm=marker
1;
