package SLight::Validator::Net;
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
# }}}

sub v_Email { # {{{
    my ( $value ) = @_;

    my ($user, $server) = ($value =~ m{^([^@]+)\@([^@]+)$}s);

    if (not $user and not $server) {
        return TR("Does not look line an Email address");
    }

    if ($user =~ m{[^0-9a-zA-Z\-\_\.]}s) {
        return TR("Account name seems broken.");
    }
    if ($server =~ m{[^0-9a-zA-Z\-\_\.]}s) {
        return TR("Server name seems broken.");
    }

    # No problems found :)
    return;
} # }}}

sub v_Url { # {{{
    my ( $value ) = @_;

    my ($protocol, $domain, $uri) = ( $value =~ m{^([a-zA-Z]+)://([^/]+)(/.*)?$}s );

    if (not $protocol and not $domain and not $uri) {
        return TR("Does not look line an URL");
    }

    # No problems found :)
    return;
} # }}}

# vim: fdm=marker
1;
