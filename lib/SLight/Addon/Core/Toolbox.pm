package SLight::Addon::Core::Toolbox;
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
use base q{SLight::Addon};

use SLight::HandlerUtils::Toolbox;

use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

# Toolbox Plugin.

sub _process { # {{{
    my ( $self, %P ) = @_;

    if (not $self->{'meta'}->{'toolbox'}) {
        return;
    }

    return SLight::HandlerUtils::Toolbox::make_toolbox(
        %{ $self->{'url'} },
        
        class => 'SLight_Toolbox_Plugin',

        urls => $self->{'meta'}->{'toolbox'}
    );
} # }}}

# vim: fdm=marker
1;
