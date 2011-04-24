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

use SLight::API::ContentSpec qw( get_ContentSpecs_where get_ContentSpec );
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
    my ( $self, $spec_id, $save ) = @_;

    return {
        '_data_order' => [
            'name',
            'short_name',
            'count_limit',
        ],
        'owning_module' => 'List::Headlines',
        '_data' => {
            'name' => {
                'display_on_page' => '2',
                'default' => '',
                'display_on_list' => '2',
                'optional' => '1',
                'caption' => 'Name',
                'display_label' => '1',
                'order' => 1,
                'translate' => '1',
                'id' => '10',
                'max_length' => '128',
                'datatype' => 'String'
            },
            'short_name' => {
                'display_on_page' => '2',
                'default' => '',
                'display_on_list' => '2',
                'optional' => '1',
                'caption' => 'Short name',
                'display_label' => '1',
                'order' => 2,
                'translate' => '1',
                'id' => '10',
                'max_length' => '128',
                'datatype' => 'String'
            },
            'count_limit' => {
                'display_on_page' => '2',
                'default' => '',
                'display_on_list' => '2',
                'optional' => '1',
                'caption' => 'Maximal headlines count',
                'display_label' => '1',
                'order' => 3,
                'translate' => '0',
                'id' => '10',
                'max_length' => '1',
                'datatype' => 'Int'
            },
        },
        'caption' => TR(q{List: Headlines}),

        'version'      => '0',
        'order_by'     => '11',
        'cms_usage'    => '3',
        'use_as_title' => undef,
        'use_in_path'  => undef,
        'use_in_menu'  => '10',
        'metadata'     => {},
        'class'        => 'Content'
    };
} # }}}

# vim: fdm=marker
1;
