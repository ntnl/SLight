package SLight::Output;
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
        object_order => undef,

        metadata => undef,

        final_data => undef,
        final_mime => undef,
    };

    bless $self, $class;

    return $self;
} # }}}

sub list_addons { # {{{
    # FIXME: actually check in the template!
    # FIXME: this should be implemented by the child classes, probably!
    return qw( Core::Toolbox Core::Path Core::Sysinfo Core::Language Core::Debug CMS::Rootmenu CMS::Menu CMS::Submenu User::Info User::Panel );
} # }}}

sub set_meta { # {{{
    my ( $self, $meta ) = @_;

    $self->{'metadata'} = $meta;

    return;
} # }}}

sub queue_addon_data { # {{{
    my ( $self, $addon, $data_structure ) = @_;

    return $self->process_addon_data($addon, $data_structure);
} # }}}

sub queue_object_data { # {{{
    my ( $self, $oid, $data_structure ) = @_;

    return $self->process_object_data($oid, $data_structure);
} # }}}

sub serialize_queued_data { # {{{
    my ( $self, %P ) = @_;

    # P should contain: template and object_order (check this/FIXME!)

    ($self->{'final_data'}, $self->{'final_mime'}) = $self->serialize($P{'object_order'}, $P{'template'});

    return;
} # }}}

sub return_response { # {{{
    my ( $self ) = @_;

    return ( $self->{'final_data'}, $self->{'final_mime'} );
} # }}}

# vim: fdm=marker
1;
