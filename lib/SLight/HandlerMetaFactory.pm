package SLight::HandlerMetaFactory;
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

# Load an Interface object.
sub make { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            pkg     => { type=>SCALAR },
            handler => { type=>SCALAR },
        }
    );

    return $self->low_load( [ 'HandlerMeta', $P{'pkg'}, $P{'handler'} ] );
} # }}}

# vim: fdm=marker
1;
