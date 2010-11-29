package SLight::Handler::Core::Empty::View;
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

use SLight::Core::L10N qw( TR );

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('Empty');

    $self->set_toolbox(
        [
            {
                caption => TR('Add content'),
                action  => 'AddContent',
            },
            {
                caption => TR('Delete'),
                action  => 'Delete',
            },
        ]
    );

    return;
} # }}}

# vim: fdm=marker
1;
