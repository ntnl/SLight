package SLight::Output;
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

use SLight::Core::Config;

use Carp::Assert::More qw( assert_defined );
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
        object_data  => {},
        object_order => undef,

        final_data => undef,
        final_mime => undef,
    };

    bless $self, $class;

    return $self;
} # }}}

sub queue_object_data { # {{{
    return;
} # }}}

sub serialize_queued_data { # {{{
    my ( $self ) = @_;

    ($self->{'final_data'}, $self->{'final_mime'}) = $self->_serialize($self->{'object_data'}, $self->{'object_order'});

    return;
} # }}}

sub return_response { # {{{
    return;
} # }}}

# vim: fdm=marker
1;
