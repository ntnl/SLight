package SLight::DataStructure::Token;
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
use base 'SLight::DataStructure';

use Params::Validate qw( :all );
# }}}

sub _new { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            token => { type=>HASHREF | ARRAYREF | SCALAR },
            class => { type=>SCALAR, optional=>1 },
        }
    );

    $self->set_data($P{'token'});

    return;
} # }}}

# vim: fdm=marker
1;
