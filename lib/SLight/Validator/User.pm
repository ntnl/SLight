package SLight::Validator::User;
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

use SLight::API::User qw( is_User_registered );

use SLight::Core::L10N qw( TR TF );
# }}}

sub v_NewLogin { # {{{
    my ( $value ) = @_;

    my $base_error = v_Login($value);
    if ($base_error) {
        return $base_error;
    }

    if (length $value < 4) {
        return TF("Too short, must have at least %d characters.", undef, 4);
    }
    
    if (is_User_registered($value) ) {
        return TR("Account with such ID already exists.");
    }

    # No problems found :)
    return;
} # }}}

sub v_Login { # {{{
    my ( $value ) = @_;

    if (length $value < 4) {
        return TF("Too short, must have at least %d characters.", undef, 4);
    }

    if ($value =~ m{[^A-Za-z0-9\@\_\-\.]}s) {
        return TR("Only numbers, Latin letters, '.', '_', '-' and '\@' are allowed.");
    }

    # No problems found :)
    return;
} # }}}

# Todo: add some strength checks.
sub v_Password { # {{{
    my ( $value, $extras ) = @_;

    if (length $value < 5) {
        return TR("Too short, must have at least 5 characters.");
    }

    if ($value ne $extras->{'pass-repeat'}) {
        return TR("Password mismatch. Enter the same password twice.");
    }

    # No problems found :)
    return;
} # }}}

# vim: fdm=marker
1;
