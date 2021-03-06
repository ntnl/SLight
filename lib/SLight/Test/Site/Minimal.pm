package SLight::Test::Site::Minimal;
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
use strict; use warnings; # {{{

use SLight::API::Asset qw( add_Asset );
use SLight::API::Content qw( add_Content );
use SLight::API::ContentSpec qw( add_ContentSpec );
use SLight::API::Page;
use SLight::Test::Site::Users;

use File::Slurp qw( read_file );
# }}}

# This module creates Minimal fake (test) site, with just 3 sub-pages.

sub build { # {{{
    # You need users, to play with content.
    SLight::Test::Site::Users::build();

    # Add root page:
    my $p0_id = SLight::API::Page::add_Page(
        parent_id => undef,
        path      => q{},
        template  => q{Default},

        L10N => {
            en => { menu => q{Test site},      title => q{Test site},      breadcrumb => q{Test site}, },
            pl => { menu => q{Strona testowa}, title => q{Strona testowa}, breadcrumb => q{Strona testowa}, },
        },
    );

    # Add 1-st level pages:
    my $p1_id = SLight::API::Page::add_Page(
        parent_id => $p0_id,
        path      => q{About},
        template  => q{Info},

        L10N => {
            en => { menu => q{About...},      title => q{About the test page},  breadcrumb => q{About the site}, },
            pl => { menu => q{Informacje...}, title => q{Informacje o stronie}, breadcrumb => q{O stronie}, },
        },
    );
    my $p2_id = SLight::API::Page::add_Page(
        parent_id => $p0_id,
        path      => q{Docs},
        template  => q{Doc},

        L10N => {
            en => { menu => q{Documentation}, title => q{Documentation}, breadcrumb => q{Documentation}, },
            pl => { menu => q{Dokumentacja},  title => q{Dokumentacja},  breadcrumb => q{Dokumentacja}, },
        },
    );
    my $p3_id = SLight::API::Page::add_Page(
        parent_id => $p0_id,
        path      => q{Download},

        L10N => {
            en => { menu => q{Download}, title => q{Download}, breadcrumb => q{Download}, },
            pl => { menu => q{Pobierz},  title => q{Pobierz},  breadcrumb => q{Pobierz}, },
        },
    );

    # Add 2-nd level pages:
    my $p4_id = SLight::API::Page::add_Page(
        parent_id => $p1_id,
        path      => q{Authors},

        L10N => {
            en => { menu => q{Authors}, title => q{Authors}, breadcrumb => q{Authors}, },
            pl => { menu => q{Autorzy}, title => q{Autorzy}, breadcrumb => q{Autorzy}, },
        },
    );

    # Add 3-rd level page:
    my $p5_id = SLight::API::Page::add_Page(
        parent_id => $p4_id,
        path      => q{Feedback},

        L10N => {
            en => { menu => q{Feedback}, title => q{Your feedback}, breadcrumb => q{Feedback}, },
            pl => { menu => q{Opinie},   title => q{Wasze opinie},  breadcrumb => q{Opinie}, },
        },
    );

    # Add some content specs:
    my $spec1_id = add_ContentSpec(
        caption => 'Article',

        _data => {
            title   => { id=>10, caption=>'Title',   datatype=>'String', field_index=>1, default_value => q{}, translate=>1, max_length=>128 },
            article => { id=>11, caption=>'Article', datatype=>'Text',   field_index=>2, default_value => q{}, translate=>1, max_length=>1024 },
        },

        class => 'Content',

        cms_usage   => 3,

#        order_by    => 11,
#        use_in_menu => 10,

        owning_module => q{CMS::Entry},
    );
    my $spec2_id = add_ContentSpec(
        caption => 'News',

        _data => {
            title => { id=>20, caption=>'Title', datatype=>'String', field_index=>1, default_value => q{}, translate=>1, max_length=>128 },
            news  => { id=>21, caption=>'News',  datatype=>'Text',   field_index=>2, default_value => q{}, translate=>1, max_length=>1024 },
        },

        class => 'Content',

        cms_usage => 3,

        owning_module => q{CMS::Entry},
    );
    my $spec3_id = add_ContentSpec(
        caption => 'Gal',

        _data => {
            name     => { id=>30, caption => 'Name',       datatype => 'String', field_index=>1, default_value => q{}, translate => 0, optional => 0, max_length => 64 },
            pic      => { id=>31, caption => 'Pic',        datatype => 'Image',  field_index=>2, default_value => q{}, translate => 0, optional => 0, max_length => 1_024_000 },
            birth    => { id=>32, caption => 'Birth date', datatype => 'Date',   field_index=>3, default_value => q{}, translate => 0, optional => 0, max_length => 64 },
            email    => { id=>33, caption => 'Email',      datatype => 'Email',  field_index=>4, default_value => q{}, translate => 0, optional => 0, max_length => 512 },
            homepage => { id=>34, caption => 'Homepage',   datatype => 'Link',   field_index=>5, default_value => q{}, translate => 0, optional => 0, max_length => 1025 },

            chest => { id=>35, caption => 'Chest',      datatype => 'Int',    field_index=>6, default_value => q{}, translate => 0, optional => 0, max_length => 3 },
            waist => { id=>36, caption => 'Waist',      datatype => 'Int',    field_index=>7, default_value => q{}, translate => 0, optional => 0, max_length => 3 },
            hips  => { id=>37, caption => 'Hips',       datatype => 'Int',    field_index=>8, default_value => q{}, translate => 0, optional => 0, max_length => 3 },
            cup   => { id=>38, caption => 'Cup size',   datatype => 'String', field_index=>9, default_value => q{}, translate => 0, optional => 0, max_length => 1 },
            
            about => { id=>39, caption => 'About', datatype => 'Text', field_index=>10, default_value => q{}, translate => 1, optional => 0, max_length => 10_240 },
        },

        class => 'Person',

        cms_usage => 1,

        owning_module => q{CMS::Entry},
    );

    my $c1 = add_Content(
        Content_Spec_id => $spec1_id,
        Page_Entity_id  => $p0_id,

        status        => q{V},
        on_page_index => 0,

        email => q{test@example.test},

        Data => {
            pl => {
                10 => { value => q{Strona testowa zrobiona}, },
                11 => { value => qq{---\n - Minimalna strona testowa, już nie taka minimalna ;)\n}, },
            },
            en => {
                10 => { value => q{Test site is up}, },
                11 => { value => qq{---\n - Minimal test site, not such minimal any more ;)\n}, },
            },
        }
    );
    my $c2 = add_Content(
        Content_Spec_id => $spec1_id,
        Page_Entity_id  => $p1_id,

        status => q{V},

        email => q{test@example.test},

        Data => {
            pl => {
                10 => { value => q{Podstrona testowa}, },
                11 => { value => qq{---\n - Minimalna strona testowa, już nie taka minimalna ;)\n}, },
            },
            en => {
                10 => { value => q{Test sub-page}, },
                11 => { value => qq{---\n - Minimal test page, not such minimal any more ;)\n}, },
            },
        }
    );

    add_Asset(
        data => scalar read_file(SLight::Test::Site::Builder::trunk_path() . q{/t/SampleImage.png}),

        email => 'test@test.test',

        filename => 'SampleImage.png',
        summary  => 'Sample image for testing purposes.',
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
