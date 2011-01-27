package SLight::DataType::Image;
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

# DataType support for Images.
use strict; use warnings; # {{{

use Params::Validate qw{ :all };
# }}}

# String:
# Single line of characters.

sub signature { # {{{
    return {
        asset => 1,
        entry => 'String',
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

    # No problems found.
    return;
} # }}}

# Those functions just pass the data, as strings, without modyfying them.

sub encode_data { # {{{
    my %P = validate(
        @_,
        {
            value  => { type=>SCALAR },
            format => { type=>SCALAR },
        }
    );

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
