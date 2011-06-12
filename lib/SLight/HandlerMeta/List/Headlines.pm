package SLight::HandlerMeta::List::Headlines;
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

use SLight::API::ContentSpec qw( get_ContentSpecs_where get_ContentSpec add_ContentSpec );
use SLight::Core::L10N qw( TR );

use Carp::Assert::More qw( assert_defined );
# }}}

sub new { # {{{
    my ( $class ) = @_;

    my $self = {};

    bless $self, $class;

    return $self;
} # }}}

sub get_spec { # {{{
    my ( $self, $spec_id ) = @_;

    # Parameters are ignored.

    my $headlines_list_spec = {
        'owning_module' => 'List::Headlines',
        '_data' => {
            'name' => {
                'display_on_page' => '2',
                'default_value' => '',
                'display_on_list' => '2',
                'optional' => '1',
                'caption' => 'Name',
                'display_label' => '1',
                'field_index' => 1,
                'translate' => '1',
                'max_length' => '128',
                'datatype' => 'String'
            },
            'short_name' => {
                'display_on_page' => '2',
                'default_value' => '',
                'display_on_list' => '2',
                'optional' => '1',
                'caption' => 'Short name',
                'display_label' => '1',
                'field_index' => 2,
                'translate' => '1',
                'max_length' => '128',
                'datatype' => 'String'
            },
            'count_limit' => {
                'display_on_page' => '2',
                'default_value' => '',
                'display_on_list' => '2',
                'optional' => '1',
                'caption' => 'Maximal headlines count',
                'display_label' => '1',
                'field_index' => 3,
                'translate' => '0',
                'max_length' => '1',
                'datatype' => 'Int'
            },
        },
        'caption' => TR(q{List: Headlines}),

        'version'      => '0',
        'cms_usage'    => '3',
        'metadata'     => {},
        'class'        => 'SL_List_Headlines'
    };
    
    # Check, if there is a correct entry in Spec DB.
    my $stored_specs = get_ContentSpecs_where(
        owning_module => 'List::Headlines',
        version       => 0,
    );

    if (scalar @{ $stored_specs }) {
#        warn "Stored";

#        use Data::Dumper; warn Dumper $stored_specs;

        return $stored_specs->[0];
    }

    my $added_spec_id = add_ContentSpec(%{ $headlines_list_spec });

#    warn "Saved";

    return get_ContentSpec($added_spec_id);
} # }}}

# vim: fdm=marker
1;
