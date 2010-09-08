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
use SLight::DataToken qw( mk_Label_token );

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $specs = get_all_ContentSpecs();

    if (not scalar @{ $specs }) {
        return SLight::DataStructure::Dialog::Notification->new(
            class => q{SLight_Notification},
            text  => TR('No specs.'),
        );
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
            caption       => $content_spec->{'caption'},
            owning_module => $content_spec->{'owning_module'},
            version       => $content_spec->{'version'},
            field_count   => scalar keys @{ $content_spec->{'_data'} },
        );
    }

    return $table;
} # }}}

# vim: fdm=marker
1;
