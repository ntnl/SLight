package SLight::HandlerMeta::Core::Empty;
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
use base 'SLight::HandlerMeta::Base';

use SLight::Core::L10N qw( TR );
# }}}

sub get_spec { # {{{
    my ( $self, $spec_id ) = @_;

    # Parameters are ignored For now..

    my $spec = {
        'owning_module' => 'Core::Empty',
        '_data' => {
        },
        'caption' => TR(q{Empty space}),

        'version'      => '0',
        'cms_usage'    => '3',
        'metadata'     => {},
        'class'        => 'SL_Core_Empty'
    };

    # Check, if there is a correct entry in Spec DB.
    # If not, add proper one.
    #
    # This is a temporal workaround. Will be improved when needed.
    return $self->check_spec(
        owning_module => 'Core::Empty',
        version       => 0,
        spec          => $spec,
    );
} # }}}

# vim: fdm=marker
1;
