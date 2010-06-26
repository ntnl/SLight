package SLight::Test::Site::Minimal;
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

use SLight::API::Page;
# }}}

# This module creates Minimal fake (test) site, with just 3 sub-pages.

sub build { # {{{
    # Add root page:
    my $p0_id = SLight::API::Page::add_page(
        parent_id => undef,
        path      => q{/},
        template  => q{Default},
    );

    my $p1_id = SLight::API::Page::add_page(
        parent_id => $p0_id,
        path      => q{About},
        template  => q{Doc},
    );
    my $p2_id = SLight::API::Page::add_page(
        parent_id => $p0_id,
        path      => q{Docs},
        template  => q{Doc},
    );
    my $p3_id = SLight::API::Page::add_page(
        parent_id => $p0_id,
        path      => q{Download},
    );

    SLight::Test::Site::Builder::make_template(
        'Default',
        qq{<!doctype html>\n}.
        qq{<html>\n}.
        qq{<body>\n}.
        qq{    <H1>Minimal test site</h1>\n}.
        qq{</body>\n}.
        qq{</html>}
    );
    SLight::Test::Site::Builder::make_template(
        'Doc',
        q{<!doctype html>\n}.
        qq{<html>\n}.
        qq{<body>\n}.
        qq{    <H1>Minimal test site - documentation</h1>\n}.
        qq{</body>\n}.
        qq{</html>}
    );
    SLight::Test::Site::Builder::make_template(
        'Error',
        q{<!doctype html>\n}.
        qq{<html>\n}.
        qq{<body>\n}.
        qq{    <H1>Minimal test site - Error!</h1>\n}.
        qq{</body>\n}.
        qq{</html>}
    );

    return;
} # }}}

# vim: fdm=marker
1;
