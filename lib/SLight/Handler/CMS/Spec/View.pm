package SLight::Handler::CMS::Spec::View;
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
use base q{SLight::HandlerBase::CMS::Spec};

use SLight::API::ContentSpec qw( get_ContentSpec );
use SLight::Core::L10N qw( TR );
use SLight::DataStructure::List::Table::Properties;
use SLight::DataToken qw( mk_Label_token mk_Link_token );

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('CMS_Spec');

    $self->set_toolbox(
        [
            {
                caption => TR('Add new Spec'),
                action  => 'New',
                path    => [
                    'Spec'
                ],
            },
            {
                caption => TR('Add new Field'),
                action  => 'New',
                path    => [
                    'Field',
                    $oid,
                ],
            },
            {
                caption => TR('Edit Spec'),
                action  => 'Edit',
                path    => [
                    'Spec',
                    $oid,
                ],
            },
            {
                caption => TR('Delete Spec'),
                action  => 'Delete',
                path    => [
                    'Spec',
                    $oid,
                ],
            },
        ]
    );

#    my $spec = get_ContentSpec($oid);
    my $spec = $metadata->{'spec'};

    my $properties = SLight::DataStructure::List::Table::Properties->new(
        caption => TR(q{Specification}) . q{:},
    );

    $properties->add_Property(
        caption => TR("Caption") . q{:},
        value   => $spec->{'caption'},
    );
    $properties->add_Property(
        caption => TR("Handling module") . q{:},
        value   => $spec->{'owning_module'},
    );
    $properties->add_Property(
        caption => TR("Version") . q{:},
        value   => $spec->{'version'},
    );

    $properties->add_Property(
        caption => TR("Order field") . q{:},
        value   => $self->make_field_label($spec, $spec->{'order_by'}),
    );
    $properties->add_Property(
        caption => TR("Title field") . q{:},
        value   => $self->make_field_label($spec, $spec->{'use_as_title'}),
    );
    $properties->add_Property(
        caption => TR("Menu field") . q{:},
        value   => $self->make_field_label($spec, $spec->{'use_in_menu'}),
    );
    $properties->add_Property(
        caption => TR("Path field") . q{:},
        value   => $self->make_field_label($spec, $spec->{'use_in_path'}),
    );

    $self->push_data($properties);

    return;
} # }}}

# vim: fdm=marker
1;
