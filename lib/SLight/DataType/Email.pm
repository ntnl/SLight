package SLight::DataType::Email;
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

# DataType support for Electronic Mail.
use strict; use warnings; # {{{

use Params::Validate qw{ :all };
# }}}

sub signature { # {{{
    return {
        asset   => 0,
        entry   => 'String',
        display => 'Email',

        validator_type => 'Email',
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

    if ($P{'value'} !~ m{^[^\@]+\@[^\@\.]+(\.[^\@\.]+)+$}s) {
        return "Not an email";
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
