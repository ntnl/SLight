#!/usr/bin/perl
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
use strict; use warnings; use utf8; # {{{
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use SLight::Test::Site;

use English qw( -no_match_vars );
use Test::More;
# }}}

plan tests =>
    + 4 # add_ContentSpec

    + 2 # update_ContentSpec (core only)
    + 2 # update_ContentSpec (with data)

    + 3 # get_ContentSpec
    + 2 # get_ContentSpecs_where
    + 2 # get_ContentSpecs_ids_where
    + 2 # get_ContentSpecs_fields_where

    + 2 # delete_ContentSpec
    + 2 # delete_ContentSpecs
;

# ToDo:
#   - test 'metadata' support!

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

use SLight::API::ContentSpec qw(
    add_ContentSpec
    update_ContentSpec
    get_ContentSpec
    get_ContentSpecs_where
    get_ContentSpec_ids_where
    get_ContentSpecs_fields_where
    delete_ContentSpec
    delete_ContentSpecs
);

SLight::Core::DB::check();

#
# run: add_ContentSpec
#

my ($t1, $t2, $t3, $t4);
is (
    $t1 = add_ContentSpec(
        caption       => q{},
        owning_module => 'Test::Test',
        version       => 0,
    ),
    1,
    'add_ContentSpec (1/4)'
);

is (
    $t1 = add_ContentSpec(
        caption       => 'Folder',
        owning_module => 'CMS::Entry',
        cms_usage     => 3,
        version       => 0,
        #                '-- later changed to '2'

        _data => {
            label   => { datatype => q{String}, caption => q{Label},   order => 1, default => q{New folder}, max_length => 128, translate => 1, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 1 },
            summary => { datatype => q{Text},   caption => q{Summary}, order => 2, default => q{},           max_length => 987, translate => 1, optional => 1, display_on_page => 1, display_on_list => 0, display_label => 1 },
            #                                                  '--- later changed to 'Overview'.                            '--- later changed to '789'
        }
    ),
    2,
    'add_ContentSpec (2/4)'
);
is (
    $t2 = add_ContentSpec(
        caption       => 'Paintball gun',
        owning_module => 'CMS::Entry',
        cms_usage     => 2,

        _data => {
            brand => { datatype => q{String}, caption => q{Brand},          order => 1, default => q{}, max_length => 75, translate => 0, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 0 },
            model => { datatype => q{String}, caption => q{Model},          order => 2, default => q{}, max_length => 75, translate => 0, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 0 },
            bps   => { datatype => q{Int},    caption => q{Balls per sec.}, order => 3, default => q{}, max_length => 50, translate => 0, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 1 },
        },
    ),
    3,
    'add_ContentSpec (3/4)'
);
is (
    $t3 = add_ContentSpec(
        caption       => 'Woman',
        owning_module => 'CMS::Entry',
        version       => 0,
        cms_usage     => 1,

        _data => {
            name       => { datatype => q{String}, caption => q{Name},       order => 1, default => q{},   max_length =>  75, translate => 0, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 1 },
            chest_size => { datatype => q{Int},    caption => q{Chest (cm)}, order => 2, default => q{90}, max_length => 250, translate => 0, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 1 },
            waist_size => { datatype => q{Int},    caption => q{Waist (cm)}, order => 3, default => q{60}, max_length => 250, translate => 0, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 1 },
            hips_size  => { datatype => q{Int},    caption => q{Hips (cm)},  order => 4, default => q{90}, max_length => 250, translate => 0, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 1 },
            cup_size   => { datatype => q{String}, caption => q{Cup size},   order => 5, default => q{A},  max_length =>   1, translate => 0, optional => 0, display_on_page => 1, display_on_list => 0, display_label => 1 },
        },
    ),
    4,
    'add_ContentSpec (4/4)'
);

#
# run: update_ContentSpec
#

is (
    update_ContentSpec(
        id => 123456,

        caption => q{This change will be ignored},
    ),
    undef,
    'update_ContentSpec - core, nonexisting ID'
);
is (
    update_ContentSpec(
        id => $t1,

        version => 2,
    ),
    undef,
    'update_ContentSpec - core, existing ID'
);
is (
    update_ContentSpec(
        id => 123456,

        _data => {
            summary => { caption => q{This change will be ignored}, max_length => 787 },
        }
    ),
    undef,
    'update_ContentSpec - data, nonexisting ID'
);
is (
    update_ContentSpec(
        id => $t1,

        _data => {
            summary => { caption => q{Overview}, max_length => 789 },
        }
    ),
    undef,
    'update_ContentSpec - data, existing ID'
);
is (
    update_ContentSpec(
        id => $t1,

        _data => {
            # This one will get deleted
            label => undef,

            # This will be added:
            caption => { id=>2, datatype => q{String}, caption => q{Label}, order => 1, default => q{New folder}, max_length => 128, translate => 1, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 1 },
        }
    ),
    undef,
    'update_ContentSpec - delete+add data entry'
);

#
# run: get_ContentSpec
#

is (
    ( get_ContentSpec(123456) ),
    undef,
    'get_ContentSpec - nonexisting id'
);

is_deeply (
    get_ContentSpec($t1),
    {
        id            => $t1,
        caption       => 'Folder',
        owning_module => 'CMS::Entry',
        cms_usage     => 3,
        version       => 2,

        _data => {
            caption => { id=>2, datatype => q{String}, caption => q{Label},    order => 1, default => q{New folder}, max_length => 128, translate => 1, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 1 },
            summary => { id=>1, datatype => q{Text},   caption => q{Overview}, order => 2, default => q{},           max_length => 789, translate => 1, optional => 1, display_on_page => 1, display_on_list => 0, display_label => 1 },
        },

        metadata => {},
    },
    'get_ContentSpec - existing id'
);

#
# run: get_ContentSpecs_where
#

is_deeply(
    get_ContentSpecs_where(
        version => 5,
    ),
    [],
    'get_ContentSpecs_where - false condition'
);

is_deeply(
    get_ContentSpecs_where(
        version => 2,
    ),
    [
        {
            id            => $t1,
            caption       => 'Folder',
            owning_module => 'CMS::Entry',
            cms_usage     => 3,
            version       => 2,

            _data => {
                caption => { id=>2, datatype => q{String}, caption => q{Label},    order => 1, default => q{New folder}, max_length => 128, translate => 1, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 1 },
                summary => { id=>1, datatype => q{Text},   caption => q{Overview}, order => 2, default => q{},           max_length => 789, translate => 1, optional => 1, display_on_page => 1, display_on_list => 0, display_label => 1 },
            },

            metadata => {},            
        }
    ],
    'get_ContentSpecs_where - correcct condition'
);

#
# run: get_ContentSpecs_ids_where
#

is_deeply(
    get_ContentSpec_ids_where(
        version => 5,
    ),
    [],
    'get_ContentSpec_ids_where - false condition'
);

is_deeply(
    get_ContentSpec_ids_where(
        version => 2,
    ),
    [ $t1 ],
    'get_ContentSpec_ids_where - correcct condition'
);

#
# run: get_ContentSpecs_fields_where
#

is_deeply(
    get_ContentSpecs_fields_where(
        version => 5,
    ),
    [],
    'get_ContentSpecs_fields_where - false condition'
);

is_deeply(
    get_ContentSpecs_fields_where(
        version => 2,

        _fields      => [qw( caption )],
        _data_fields => [qw( caption order )],
    ),
    [
        {
            id => 2,

            caption => 'Folder',

            _data => {
                caption => { caption => q{Label},    order => 1 },
                summary => { caption => q{Overview}, order => 2 },
            },

            metadata => {},
        }
    ],
    'get_ContentSpecs_fields_where - correcct condition'
);

#
# run: delete_ContentSpec
#

is (
    delete_ContentSpec(1234),
    1,
    'delete_ContentSpec - nonexisting id'
);

is (
    delete_ContentSpec($t1),
    1,
    'delete_ContentSpec - existing id'
);

#
# run: delete_ContentSpecs
#

is (
    delete_ContentSpecs([ 123, 456 ]),
    2,
    'delete_ContentSpecs - nonexisting ids'
);

is (
    delete_ContentSpecs([ $t3, $t4 ]),
    2,
    'delete_ContentSpecs - existing ids'
);

# vim: fdm=marker
