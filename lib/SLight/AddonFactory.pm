package SLight::AddonFactory;
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
use base q{SLight::Core::Factory};

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

# Load an Interface object.
sub make { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            addon => { type=>SCALAR },
        }
    );

    return $self->low_load( [ 'Addon', $P{'addon'} ] );
} # }}}

# vim: fdm=marker
1;
