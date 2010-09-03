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
    my ( $self, $data_structure ) = @_;

    # use process_object_data!

    return;
} # }}}

sub serialize_queued_data { # {{{
    my ( $self, %P ) = @_;

    # P should contain: template and object_order (check this/FIXME!)

    ($self->{'final_data'}, $self->{'final_mime'}) = $self->serialize($self->{'object_data'}, $P{'object_order'}, $P{'template'});

    return;
} # }}}

sub return_response { # {{{
    my ( $self ) = @_;

    return ( $self->{'final_data'}, $self->{'final_mime'} );
} # }}}

# vim: fdm=marker
1;