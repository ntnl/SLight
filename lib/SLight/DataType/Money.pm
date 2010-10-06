package SLight::DataType::Money;
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

# DataType support for Monetary values: Money.
use strict; use warnings; # {{{

use Params::Validate qw{ :all };
# }}}

# Since 'classic' data types (float, real) are not good at storing
# monetary values, a special data type for it must be used.
# This solves issues with rounding errors.
#
# Money data type always stores it's value as string, not as a number.
#
# Note:
#   Currently this type accepts dots as 'cent' separator.

sub signature { # {{{
    return {
        asset   => 0,
        entry   => 'String',
        display => 'Label',

        validator_type => 'Float',
    };
} # }}}

sub validate_data { # {{{
    my %P = validate(
        @_,
        {
            value  => { type=>SCALAR },
            format => { type=>SCALAR },
        }
    );

    if ($P{'value'} !~ m{^[0-9]+(\.\d{1,3})?$}s) {
        return "Not a good monetary value";
    }

    # No problems found.
    return;
} # }}}

sub encode_data { # {{{
    my %P = validate(
        @_,
        {
            value  => { type=>SCALAR },
            format => { type=>SCALAR },
        }
    );
    
    $P{'value'} =~ s{\.}{_}s;

    return $P{'value'};
} # }}}

sub decode_data { # {{{
    my %P = validate(
        @_,
        {
            value  => { type=>SCALAR },
            format => { type=>SCALAR },
            target => { type=>SCALAR },
        }
    );
    
    $P{'value'} =~ s{_}{\.}s;

    return $P{'value'};
} # }}}

# vim: fdm=marker
1;
