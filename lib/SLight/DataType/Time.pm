package SLight::DataType::Time;
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

# DataType support for Time.
use strict; use warnings; # {{{

use Date::Calc qw{ Mktime Localtime };
use Params::Validate qw{ :all };
# }}}

# Date:
# Time and date.

sub signature { # {{{
    return {
        attachment => 0,
        entry      => 'String',
        display    => 'Label',

        validator_type => 'ISO_DateTime',
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

    if ($P{'value'} !~ m{^\d\d\d\d-\d\d-\d\d \d\d:\d\d(:\d\d)?$}s) {
        return "Not a valid date/time string";
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
    
    my $timestamp = 0;

    if ($P{'value'} =~ m{^(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d)(:(\d\d))?$}s) {
        my ($year, $mon, $day,  $hour, $min, $sec) = ($1, $2, $3,  $4, $5, ($7 or 0));
        
        $timestamp = Mktime ($year, $mon, $day,  $hour, $min, $sec);
    }

    return $timestamp;
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

    my ($year, $mon, $day,  $hour, $min, $sec) = Localtime ($P{'value'} );

    if ($sec) {
        return sprintf "%04d-%02d-%02d %02d:%02d:%02d", $year, $mon, $day,  $hour, $min, $sec;
    }

    return sprintf "%04d-%02d-%02d %02d:%02d", $year, $mon, $day,  $hour, $min;
} # }}}

# vim: fdm=marker
1;
