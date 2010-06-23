package SLight::Protocol;
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

use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub new { # {{{
    my $class = shift;
    my %P = validate(
        @_,
        {
        }
    );

    # Prototype of the object:
    my $self = {
    };

    bless $self, $class;

    return $self;
} # }}}

sub response_CONTENT { # {{{
    my ( $self, $content, $mime ) = @_;

    return {
        response => 'CONTENT',

        content   => $content,
        mime_type => $mime,
    };
} # }}}

# vim: fdm=marker
1;

