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

use SLight::API::Content qw( add_Content );
use SLight::API::ContentSpec qw( add_ContentSpec );
use SLight::API::Page;
# }}}

# This module creates Minimal fake (test) site, with just 3 sub-pages.

sub build { # {{{
    # Add root page:
    my $p0_id = SLight::API::Page::add_page(
        parent_id => undef,
        path      => q{},
        template  => q{Default},
    );

    # Add 1-st level pages:
    my $p1_id = SLight::API::Page::add_page(
        parent_id => $p0_id,
        path      => q{About},
        template  => q{Info},
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

    # Add 2-nd level pages:
    my $p4_id = SLight::API::Page::add_page(
        parent_id => $p1_id,
        path      => q{Authors},
    );

    # Add some content specs:
    my $spec1_id = add_ContentSpec(
        caption => 'Article',

        _data => {
            title   => { id=>10, caption=>'Title',   datatype=>'String', order=>1, default => q{}, translate=>1, max_length=>128 },
            article => { id=>11, caption=>'Article', datatype=>'Text',   order=>2, default => q{}, translate=>1, max_length=>1024 },
        },

        cms_usage => 3,

        owning_module => q{CMS::Entry},
    );
    my $spec2_id = add_ContentSpec(
        caption => 'News',

        _data => {
            title => { id=>20, caption=>'Title', datatype=>'String', order=>1, default => q{}, translate=>1, max_length=>128 },
            news  => { id=>21, caption=>'News',  datatype=>'Text',   order=>2, default => q{}, translate=>1, max_length=>1024 },
        },

        cms_usage => 3,

        owning_module => q{CMS::Entry},
    );
    my $spec3_id = add_ContentSpec(
        caption => 'Gal',

        _data => {
            name     => { id=>30, caption => 'Chest',      datatype => 'String', order=>1, default => q{}, translate => 0, optional => 0, max_length => 3 },
            pic      => { id=>31, caption => 'Pic',        datatype => 'Image',  order=>2, default => q{}, translate => 0, optional => 0, max_length => 3 },
            birth    => { id=>32, caption => 'Birth date', datatype => 'Date',   order=>3, default => q{}, translate => 0, optional => 0, max_length => 1 },
            email    => { id=>33, caption => 'Email',      datatype => 'Email',  order=>4, default => q{}, translate => 0, optional => 0, max_length => 3 },
            homepage => { id=>34, caption => 'Homepage',   datatype => 'Link',   order=>5, default => q{}, translate => 0, optional => 0, max_length => 3 },

            chest => { id=>35, caption => 'Chest',      datatype => 'Int',    order=>6, default => q{}, translate => 0, optional => 0, max_length => 3 },
            waist => { id=>36, caption => 'Waist',      datatype => 'Int',    order=>7, default => q{}, translate => 0, optional => 0, max_length => 3 },
            hips  => { id=>37, caption => 'Hips',       datatype => 'Int',    order=>8, default => q{}, translate => 0, optional => 0, max_length => 3 },
            cup   => { id=>38, caption => 'Cup size',   datatype => 'String', order=>9, default => q{}, translate => 0, optional => 0, max_length => 1 },
            
            about => { id=>39, caption => 'About', datatype => 'Text', order=>10, default => q{}, translate => 1, optional => 0, max_length => 1 },
        },

        cms_usage => 1,

        owning_module => q{CMS::Entry},
    );

    my $c1 = add_Content(
        Content_Spec_id => $spec1_id,
        Page_Entity_id  => $p0_id,

        status => q{V},

        _data => {
            pl => {
                10 => q{Strona testowa zrobiona},
                11 => qq{---\n - Minimalna strona testowa, już nie taka minimalna ;)\n},
            },
            en => {
                10 => q{Test site is up},
                11 => qq{---\n - Minimal test site, not such minimal any more ;)\n},
            },
        }
    );

    # Add gals, as authors, of course :-D Isn't that screwed? nooo.... :-P

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
        'Info',
        q{<!doctype html>\n}.
        qq{<html>\n}.
        qq{<body>\n}.
        qq{    <H1>Minimal test site - info</h1>\n}.
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
