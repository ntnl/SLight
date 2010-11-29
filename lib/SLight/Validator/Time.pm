package SLight::Validator::Time;
################################################################################
# 
# SLight - Lightweight Content Management System.
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

use SLight::Core::L10N qw( TR TF );

use Date::Calc;
# }}}

sub v_ISO_Date { # {{{
    my ( $value ) = @_;

    if ($value !~ m{^\d\d\d\d\-\d\d\-\d\d$}s) {
        return TR("Date format not recognized. Please use: YYYY-MM-DD format.");
    }

    return;
} # }}}

sub v_ISO_Time { # {{{
    my ( $value ) = @_;
    
    if ($value !~ m{^\d\d\:\d\d(\:\d\d)?$}s) {
        return TR("Time format not recognized. Please use: hh:mm or hh:mm:ss format.");
    }

    return;
} # }}}

sub v_ISO_DateTime { # {{{
    my ( $value ) = @_;

    if ($value !~ m{^\d\d\d\d\-\d\d\-\d\d \d\d:\d\d(:\d\d)$}s) {
        return TR("Date format not recognized. Please use: YYYY-MM-DD hh:mm:ss format.");
    }

    return;
} # }}}

# vim: fdm=marker
1;
