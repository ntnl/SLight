package SLight::API::ContentSpec;
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
use base 'Exporter';

use SLight::Core::Entity;

use Params::Validate qw( :all );
# }}}

our @EXPORT_OK = qw(
    add_ContentSpec
    update_ContentSpec
    get_ContentSpec
    get_ContentSpec_ids_where
    get_ContentSpecs_where
    get_ContentSpecs_fields_where
    get_all_ContentSpecs
    delete_ContentSpec
    delete_ContentSpecs
);
our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

# TODO: Port to Accessor.pm

my $_handler = SLight::Core::Entity->new( # {{{
    base_table  => 'Content_Spec',
    child_table => 'Content_Spec_Field',
 
    child_key => 'class',

    has_metadata => 1,

    data_fields       => [qw( caption owning_module class cms_usage version )],
    child_data_fields => [qw( id class field_index datatype caption default_value translate display_on_page display_on_list display_label optional max_length )],

    cache_namespage => 'SLight::API::ContentType',
); # }}}

sub add_ContentSpec { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    return $_handler->add_ENTITY(%P);
} # }}}

sub update_ContentSpec { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    return $_handler->update_ENTITY(%P);
} # }}}

sub get_ContentSpec { # {{{
    my ( $id ) = @_; # Fixme: use Params::Validate here!

    my $content_spec = $_handler->get_ENTITY($id);

    return _fix_spec($content_spec);
} # }}}

sub get_ContentSpecs_where { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    my $content_specs = $_handler->get_ENTITYs_where(%P);

    foreach my $content_spec (@{ $content_specs }) {
        _fix_spec($content_spec);
    }

    return $content_specs;
} # }}}

sub get_ContentSpecs_fields_where { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    my $content_specs = $_handler->get_ENTITYs_fields_where(%P);

    foreach my $content_spec (@{ $content_specs }) {
        _fix_spec($content_spec);
    }

    return $content_specs;
} # }}}

sub get_ContentSpec_ids_where { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    return $_handler->get_ENTITY_ids_where(%P);
} # }}}

sub get_all_ContentSpecs { # {{{
    my $content_specs = $_handler->get_all_ENTITYs();

    foreach my $content_spec (@{ $content_specs }) {
        _fix_spec($content_spec);
    }

    return $content_specs;
} # }}}

sub _fix_spec {  # {{{
    my ( $content_spec ) = @_;

    if (not $content_spec) {
        return;
    }

    if ($content_spec->{'_data'}) {
        $content_spec->{'_data_order'} = [
            sort { $content_spec->{'_data'}->{$a}->{'field_index'} <=> $content_spec->{'_data'}->{$b}->{'field_index'} } keys %{ $content_spec->{'_data'} }
        ];
    }

    return $content_spec;
} # }}}

sub delete_ContentSpec { # {{{
    my ( $id ) = @_; # Fixme: use Params::Validate here!

    return $_handler->delete_ENTITY($id);
} # }}}

sub delete_ContentSpecs { # {{{
    my ( $ids ) = @_; # Fixme: use Params::Validate here!

    return $_handler->delete_ENTITYs($ids);
} # }}}


# vim: fdm=marker
1;
