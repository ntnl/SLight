package SLight::HandlerBase::ProxyAction;
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

# This is just a proxy action for SLight::Handler::Core::Empty::AddContent.

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->replace_with_object(
        class    => $self->target_object(),
        oid      => $oid,
        metadata => $metadata,
    );

    return;
} # }}}

sub handle_form { # {{{
    my ( $self, $oid, $metadata ) = @_;
    return $self->handle_view();
} # }}}

sub handle_preview { # {{{
    my ( $self, $oid, $metadata ) = @_;
    return $self->handle_view();
} # }}}

sub handle_save { # {{{
    my ( $self, $oid, $metadata ) = @_;
    return $self->handle_view();
} # }}}

# vim: fdm=marker
1;
