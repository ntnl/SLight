package SLight::Handler::Core::AssetList::View;
################################################################################
# 
# SLight - Lightweight Content Management System.
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
use base q{SLight::Handler};

use SLight::API::Asset qw( get_Assets get_Asset_data get_Asset_ids_where );
use SLight::Core::L10N qw( TR );
use SLight::DataStructure::List::Table;
use SLight::DataStructure::Dialog::Notification;
use SLight::DataToken qw( mk_Label_token mk_Link_token mk_Image_token);

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('Assets');

    $self->add_to_path_bar(
        label => TR('Assets'),
        url   => {},
    );

    # Check if the asset exists:
    my $asset_ids = get_Asset_ids_where(
#        debug => 1,
    );

    if (not scalar @{ $asset_ids }) {
        $self->push_data(
            SLight::DataStructure::Dialog::Notification->new(
                class => q{SLight_Notification},
                text  => TR('No assets.'),
            )
        );

        return;
    }
    
    my $table = SLight::DataStructure::List::Table->new(
        columns => [
            {
                name  => 'thumb',
                class => 'SLight_thumb',
                label => q{},
            },
            {
                name  => 'summary',
                class => 'SLight_main_name',
                label => TR('Summary'),
            },
            {
                name  => 'mime_type',
                class => 'SLight_mime',
                label => TR('Mime type'),
            },
            {
                name  => 'added',
                class => 'SLight_time',
                label => TR('Added'),
            },
            {
                name  => 'actions',
                class => 'SLight_toolbox',
                label => TR('Actions'),
            },
        ]
    );

    my $assets = get_Assets($asset_ids);
    foreach my $asset (@{ $assets }) {
        my $thumb_url = $self->build_url(
            path_handler => 'Asset',
            action       => 'Thumb',
            path         => [ 'Asset', $asset->{'id'}, ],
        );

        $table->add_Row(
            data => {
                thumb => [
                    mk_Image_token(
                        class => 'Asset',
                        href  => $thumb_url,
                        label => ( $asset->{'summary'} or $asset->{'filename'} or q{-} ),
                    ),
                ],
                summary   => ( $asset->{'summary'} or q{-} ),
                mime_type => $asset->{'mime_type'},
                added     => ( $asset->{'added'} or q{-} ),
                actions   => [
                    $self->make_toolbox(
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
                        ],
                    ),
                ],
            }
        );
    }

    $self->push_data($table);

    return;
} # }}}

# vim: fdm=marker
1;
