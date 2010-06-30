package SLight::Validator::Simple;
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

use SLight::Core::L10N qw( TR TF );
# }}}

# Accept only ASCII letters and numbers.
sub v_ASCII { # {{{
    my ( $value ) = @_;
    
    if ($value =~ m{[^A-Za-z0-9]}s) {
        return TR("Only numbers and English letters are allowed.");
    }

    return;
} # }}}

# Accept any string of printable characters.
sub v_String { # {{{
    my ( $value ) = @_;
    
    if ($value =~ m{[\0\t\n\r]}s) {
        return TR("Contains some not allowed unprintable characters.");
    }

    return;
} # }}}

# Accept all characters, beside non-printable ones.
# Exception to this is the newline (\n) and carrage return (\r).
sub v_Text { # {{{
    my ( $value ) = @_;

    if ($value =~ m{[\0\t]}s) {
        return TR("Contains some not allowed unprintable characters.");
    }

    return;
} # }}}

sub v_Integer { # {{{
    my ( $value ) = @_;

    if ($value !~ m{^(\-|\+)?\d+$}s) {
        return TR("Not an integer");
    }

    # No problems found :)
    return;
} # }}}

# vim: fdm=marker
1;
