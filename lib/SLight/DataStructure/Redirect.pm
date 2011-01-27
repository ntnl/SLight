package SLight::DataStructure::Redirect;
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
use base 'SLight::DataStructure';

use SLight::DataToken qw( mk_Link_token );

use Params::Validate qw( :all );
# }}}

sub _new { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            href => { type=>SCALAR },
        }
    );

    $self->set_data(
        mk_Link_token(
            text => q{Redirect....},
            href => $P{'href'},
        ),
    );

    return;
} # }}}

# vim: fdm=marker
1;

