package SLight::AddonFactory;
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
use base q{SLight::Core::Factory};

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

# Load an Addon object.
sub make { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            pkg   => { type=>SCALAR },
            addon => { type=>SCALAR },
        }
    );

    return $self->low_load( [ 'Addon', $P{'pkg'}, $P{'addon'} ] );
} # }}}

# vim: fdm=marker
1;
