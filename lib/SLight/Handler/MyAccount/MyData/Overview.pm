package SLight::Handler::MyAccount::MyData::Overview;
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
use base q{SLight::HandlerBase::User::MyAccount};

# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $user_data = ( $self->get_user_data() or return );

    

    return;
} # }}}

# vim: fdm=marker
1;
