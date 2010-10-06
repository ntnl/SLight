package SLight::DataType::String;
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

# DataType support for String.
use strict; use warnings; # {{{

use Params::Validate qw{ :all };
# }}}

# String:
# Single line of characters.

sub signature { # {{{
    return {
        asset   => 0,
        entry   => 'String',
        display => 'Label',

        validator_type => 'String',
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

    if ($P{'value'} =~ m{[\n\r]}s) {
        return "More then one line";
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

    $P{'value'} =~ s{^[\s\t]+}{}s;
    $P{'value'} =~ s{[\s\t]+$}{}s;

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

    return $P{'value'};
} # }}}

# vim: fdm=marker
1;
