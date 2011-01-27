package SLight::DataType::Int;
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

# DataType support for Int.
use strict; use warnings; # {{{

use Params::Validate qw{ :all };
# }}}

# Return information about the DataType.
sub signature { # {{{
    return {
        asset => 0,
            # How to handle data:
            # 0 - works on the data directly.
            # 1 - wowks on the path of file (usually attached to the field).

        entry => 'String',
            # What type of input widget to use, one of:
            # String
            # Text

        display => 'Label',
            # What widget type to use:
            # Label - for simple stuff
            # Text  - for more lines of text
            # Link  - for hipertext links 
            # Email - for electronic mails
        
        validator_type => 'Integer',
            # What Validator function UI should use.
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

    if ($P{'value'} !~ m{^[0-9]+$}s) {
        return "Not a number";
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
