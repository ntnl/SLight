package SLight::Handler::CMS::SpecList::View;
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
use base q{SLight::Handler};

use SLight::API::ContentSpec qw( get_all_ContentSpecs );
use SLight::Core::L10N qw( TR );
use SLight::DataStructure::List::Table;
use SLight::DataStructure::Dialog::Notification;
use SLight::DataToken qw( mk_Label_token mk_Link_token );

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_toolbox(
        [
            {
                caption => TR('Add new Spec'),
                action  => 'New',
                path    => [
                    'Spec'
                ],
            }
        ]
    );

    $self->add_to_path_bar(
        label => TR('Content Specification list'),
        url   => {},
    );

    my $specs = get_all_ContentSpecs();

    if (not scalar @{ $specs }) {
        $self->push_data(
            SLight::DataStructure::Dialog::Notification->new(
                class => q{SLight_Notification},
                text  => TR('No specs.'),
            )
        );

        return;
    }

    my $table = SLight::DataStructure::List::Table->new(
        columns => [
            {
                name  => 'caption',
                class => 'SLight_main_name',
                label => TR('Caption'),
            },
            {
                name  => 'owning_module',
                class => 'SLight_name',
                label => TR('Owner'),
            },
            {
                name  => 'version',
                class => 'SLight_int',
                label => TR('Version'),
            },
            {
                name  => 'field_count',
                class => 'SLight_int',
                label => TR('Amount of fields'),
            }
        ]
    );

    foreach my $content_spec (@{ $specs }) {
        $table->add_Row(
            data => {
                caption => [
                    mk_Link_token(
                        text => $content_spec->{'caption'},
                        href => $self->build_url(
                            path => [ 'Spec', $content_spec->{'id'}, ],
                        ),
                    ),
                ],
                owning_module => $content_spec->{'owning_module'},
                version       => $content_spec->{'version'},
                field_count   => scalar keys %{ $content_spec->{'_data'} },
            },
        );
    }

    $self->push_data($table);

    return;
} # }}}

# vim: fdm=marker
1;
