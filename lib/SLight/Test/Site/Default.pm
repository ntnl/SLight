package SLight::Test::Site::Default;
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

# This test site represents the default SLight installation.
# It is used primary to see if SLight works out of the box,
# but the dump can be used as a starting point for new site.

sub build { # {{{
    my $spec1_id = add_ContentSpec(
        caption => 'News',

        _data => {
            title => { caption=>'Title',   datatype=>'String', field_index=>1, default_value => q{}, translate => 1, max_length=>128 },
            news  => { caption=>'Article', datatype=>'Text',   field_index=>2, default_value => q{}, translate => 1, max_length=>1024 },
        },

        class => 'News',

        cms_usage => 3,

        owning_module => q{CMS::Entry},
    );
    my $spec2_id = add_ContentSpec(
        caption => 'Article',

        _data => {
            title   => { caption=>'Title',   datatype=>'String', field_index=>1, default_value => q{}, translate => 1, max_length=>128 },
            article => { caption=>'Article', datatype=>'Text',   field_index=>2, default_value => q{}, translate => 1, max_length=>10240 },
        },

        class => 'Article',

        cms_usage => 3,

        owning_module => q{CMS::Entry},
    );

    return;
} # }}}

# vim: fdm=marker
1;
