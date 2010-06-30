package SLight::Test::Validator;
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

use SLight::Validator;

use Params::Validate qw( :all );
use Test::FileReferenced;
use Test::More;
# }}}

# Each test should contain: {
#   name : SCALAR
#       # Human-readable name
#
#   data : HASHREF
#       # Data, that will be validated.
#
#   meta : HASHREF
#       # Metadata, that will be passed to Validator.
#
#   expect : undef
#       # Optional
#       # If no erroes are expected, use this key, and set it to undef.
# }
sub run_tests { # {{{
    my %P = validate(
        @_,
        {
            tests  => { type=>ARRAYREF },
        }
    );

    plan tests => scalar @{ $P{'tests'} };

    foreach my $t (@{ $P{'tests'} }) {
        is_referenced_ok(
            ( SLight::Validator::validate_input($t->{'data'}, $t->{'meta'}) or undef ),
            $t->{'name'},
        );
    }

    return;
} # }}}

# vim: fdm=marker
1;
