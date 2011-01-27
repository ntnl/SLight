package SLight::Handler::Core::Asset::View;
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

use SLight::API::Asset qw( get_Asset );
use SLight::Core::L10N qw( TR );
use SLight::DataStructure::Properties;

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('Asset');

    # Check if the asset exists:
    my $asset = get_Asset($oid);
    
    my $thumb_url = $self->build_url(
        path_handler => 'Asset',
        action       => 'Thumb',
        path         => [ 'Asset', $asset->{'id'}, ],
    );

    my $properties = SLight::DataStructure::Properties->new(
        caption => TR(q{Asset details:}),
    );
    
    $properties->add_Property(
        caption => TR("Filename") . q{:},
        value   => $asset->{'filename'},
    );
    $properties->add_Property(
        caption => TR("Mime type") . q{:},
        value   => $asset->{'mime_type'},
    );
    $properties->add_Property(
        caption => TR("Summary") . q{:},
        value   => $asset->{'summary'},
    );

    $self->push_data($properties);
    
    $self->push_toolbox(
        urls => [
            {
                caption => TR('Download'),
                action  => 'Download',
                path    => [
                    'Asset',
                    $asset->{'id'},
                ],
            },
            {
                caption => TR('Delete'),
                action  => 'Delete',
                path    => [
                    'Asset',
                    $asset->{'id'},
                ],
            },
        ]
    );

    return;
} # }}}

# vim: fdm=marker
1;
