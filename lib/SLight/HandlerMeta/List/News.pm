package SLight::HandlerMeta::List::News;
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
use base 'SLight::HandlerMeta::List';

use SLight::Core::L10N qw( TR );

use Carp::Assert::More qw( assert_defined );
# }}}

sub get_spec { # {{{
    my ( $self, $spec_id ) = @_;

    # Parameters are ignored. For now.

    my $headlines_list_spec = {
        'owning_module' => 'List::Headlines',
        '_data' => {
            'count_limit' => {
                'display_on_page' => '2',
                'default_value'   => '',
                'display_on_list' => '2',
                'optional'        => '1',
                'caption'         => 'Maximal headlines count',
                'display_label'   => '1',
                'field_index'     => 3,
                'translate'       => '0',
                'max_length'      => '1',
                'datatype'        => 'Int'
            },
            'read_more' => {
                'display_on_page' => '2',
                'default_value'   => 'Read more...',
                'display_on_list' => '2',
                'optional'        => '1',
                'caption'         => 'Action link text',
                'display_label'   => '1',
                'field_index'     => 2,
                'translate'       => '1',
                'max_length'      => '128',
                'datatype'        => 'String'
            },
        },
        'caption' => TR(q{List: Headlines}),

        'version'      => '0',
        'cms_usage'    => '3',
        'metadata'     => {},
        'class'        => 'SL_List_Headlines'
    };

    # Check, if there is a correct entry in Spec DB.
    # If not, add proper one.
    return $self->check_spec(
        owning_module => 'List::Headlines',
        version       => 0,
        spec          => $headlines_list_spec,
    );

} # }}}

# vim: fdm=marker
1;
