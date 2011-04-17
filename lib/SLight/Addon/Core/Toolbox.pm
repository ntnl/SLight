package SLight::Addon::Core::Toolbox;
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

use SLight::HandlerUtils::Toolbox;

use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub _process { # {{{
    my ( $self ) = @_;

#    use Data::Dumper; warn 'In-addon metadata: ' . Dumper $self->{'meta'};

    if (not $self->{'meta'}->{'toolbox'}) {
        return;
    }

    my %params = (
        class => 'SLight_Toolbox_Plugin',

        urls => $self->{'meta'}->{'toolbox'},
    );
    
    if ($self->{'user'}->{'id'}) {
        $params{'user_id'} = $self->{'user'}->{'id'};
    }

    return SLight::HandlerUtils::Toolbox::make_toolbox(
        %{ $self->{'url'} },
        
        %params,
    );
} # }}}

# vim: fdm=marker
1;
