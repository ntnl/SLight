package SLight::HandlerMeta::List::Gallery;
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

    my $gallery_list_spec = {
        'owning_module' => 'List::Gallery',
        '_data' => {
        },
        'caption' => TR(q{List: Gallery}),

        'version'      => '0',
        'cms_usage'    => '3',
        'metadata'     => {},
        'class'        => 'SL_List_Gallery'
    };

    # Check, if there is a correct entry in Spec DB.
    # If not, add proper one.
    return $self->check_spec(
        owning_module => 'List::Gallery',
        version       => 0,
        spec          => $gallery_list_spec,
    );

} # }}}

# vim: fdm=marker
1;
