package SLight::Handler;
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
use base q{SLight::BaseClass};

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

# Load an Interface object.
sub new { # {{{
    my $class = shift;
    my %P = validate(
        @_,
        {
        }
    );

    # Prototype of the object:
    my $self = {
    };

    bless $self, $class;

    return $self;
} # }}}

# vim: fdm=marker
1;
