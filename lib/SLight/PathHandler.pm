package SLight::PathHandler;
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

my $VERSION = '0.0.1';

# }}}

# Make a new PathHandler object. Nothing fancy here.
sub new { # {{{
    my ( $class ) = @_;

    my $self = {
        template => undef,

        objects => [],
        addons  => [],
    };

    bless $self, $class;

    return $self;
} # }}}

sub response_content { # {{{
    my ( $self ) = @_;

    return {
        template => $self->{'template'},
        
        objects => $self->{'objects'},
        
        addons => $self->{'addons'},
    };
} # }}}

# vim: fdm=marker
1;
