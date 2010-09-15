package SLight::DataType;
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

use Carp::Assert::More qw( assert_is );

use Params::Validate qw( :all );
# }}}

# Validate data from forms so User can see a clear warning.
#   type   => # DataType code name.
#   value  => # Value, as it was entered by the user, usually a string of characters.
#   format => # Format in which the DataType is expecting the value. Optional.
sub validate_data { # {{{
    my %P = validate(
        @_,
        {
            type   => { type=>SCALAR },
            value  => { type=>SCALAR },
            format => { type=>SCALAR, optional=>1, default=>q{} },
        }
    );
    
    return run_function(
        type     => $P{'type'},
        function => q{validate_data},
        params   => {
            value  => $P{'value'},
            format => $P{'format'},
        },
    );
} # }}}

# Process data from forms so it can be stored in data storage.
#   type   => # DataType code name.
#   value  => # Value, as it was entered by the user, usually a string of characters.
#   format => # Format in which the DataType is expecting the value. Optional.
sub encode_data { # {{{
    my %P = validate(
        @_,
        {
            type   => { type=>SCALAR },
            value  => { type=>SCALAR },
            format => { type=>SCALAR, optional=>1, default=>q{} },
        }
    );
    
    my $errors = scalar run_function(
        type     => $P{'type'},
        function => q{validate_data},
        params   => {
            value  => $P{'value'},
            format => $P{'format'},
        },
    );
    assert_is($errors, undef, 'Data passed validation');

    return run_function(
        type     => $P{'type'},
        function => q{encode_data},
        params   => {
            value  => $P{'value'},
            format => $P{'format'},
        },
    );
} # }}}

# Process data from database, so it can be shown on page or used in
# forms. Different data can be returned depending on the 'target'
# option. Targets supported by every DataType are:
#   MAIN - will be put into the result as main content
#   LIST - will be put into the result as list content
#   FORM - will be put into the result as a form field value
# Parameters:
#   type   => # DataType code name.
#   value  => # Value, as it was returned by the database.
#   format => # Format in which the DataType is to be returned. Optional.
#   target => # Where the data is to be shown.
sub decode_data { # {{{
    my %P = validate(
        @_,
        {
            type   => { type=>SCALAR },
            value  => { type=>SCALAR },
            format => { type=>SCALAR, optional=>1, default=>q{} },
            target => { type=>SCALAR },
        }
    );

    return run_function(
        type     => $P{'type'},
        function => q{decode_data},
        params   => {
            value  => $P{'value'},
            format => $P{'format'},
            target => $P{'target'},
        },
    );
} # }}}

# Run selected function fron selected module.
sub run_function { # {{{
    my %P = validate(
        @_,
        {
            type     => { type=>SCALAR },
            function => { type=>SCALAR },
            params   => { type=>HASHREF },
        }
    );

    check_or_register(
        type => $P{'type'}
    );

    my $function_reference = \&{ 'SLight::DataType::'. $P{'type'} .q{::}. $P{'function'} };

    return &{ $function_reference }( %{ $P{'params'} } );
} # }}}

my %signatures;

# Check if DataType module is loaded.
sub check_or_register { # {{{
    my %P = validate(
        @_,
        {
            type => { type=>SCALAR },
        }
    );

    if ($signatures{ $P{'type'} }) {
        # Already registered.
        return;
    }

    my $name = q{SLight/DataType/}. $P{'type'} .q{.pm};

    require $name;

    # Initialize this entry, so that 'run_function' does not want to initialize it again...
    # If we omit this, a deep recursion will occur.
    $signatures{ $P{'type'} } = {};

    # Get the type's signature.
    $signatures{ $P{'type'} } = run_function( type=>$P{'type'}, function=>'signature', params=>{} );

    return;
} # }}}

sub signature { # {{{
    my %P = validate(
        @_,
        {
            type => { type=>SCALAR },
        }
    );
    
    check_or_register(
        type => $P{'type'}
    );

    # We will always have this.
    # IF the type is bogus, then the above function will die.
    return $signatures{ $P{'type'} };
} # }}}

# vim: fdm=marker
1;
