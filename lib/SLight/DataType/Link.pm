package SLight::DataType::Link;
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

# DataType support for HTTP Hyper Links: Link.
use strict; use warnings; # {{{

use Params::Validate qw{ :all };
# }}}

sub signature { # {{{
    return {
        asset   => 0,
        entry   => 'String',
        display => 'Link',

        validator_type => 'URL',
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

    if ($P{'value'} !~ m{^[a-z]+://([^/]+)(/.*)?$}s) {
        return "Not a link";
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
