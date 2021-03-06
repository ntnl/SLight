package SLight::Handler::CMS::SpecField::View;
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
use base q{SLight::Handler};

use SLight::API::ContentSpec qw( get_ContentSpec );
use SLight::Core::L10N qw( TR );
use SLight::DataStructure::Properties;
use SLight::DataToken qw( mk_Label_token mk_Link_token );

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('CMS_Spec_Field');

    my $spec = $metadata->{'spec'};

#    use Data::Dumper; warn Dumper $spec;

    my $field = $spec->{'_data'}->{$oid};

    my $properties = SLight::DataStructure::Properties->new(
        caption => TR(q{Field}) .q{:},
    );
    
    $properties->add_Property(
        caption => TR("Caption") . q{:},
        value   => $field->{'caption'},
    );

    $properties->add_Property(
        caption => TR("Data type") . q{:},
        value   => $field->{'datatype'},
    );

    $self->push_data($properties);

    $self->push_toolbox(
        urls => [
            {
                caption => TR('Edit'),
                action  => 'Edit',
                path    => [
                    'Field',
                    $spec->{'id'},
                    $oid,
                ],
            },
            {
                caption => TR('Delete'),
                action  => 'Delete',
                path    => [
                    'Field',
                    $spec->{'id'},
                    $oid,
                ],
            },
        ]
    );

    return;
} # }}}

# vim: fdm=marker
1;
