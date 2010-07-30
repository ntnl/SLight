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

#    + 2 # update_ContentSpec (core only)
#    + 2 # update_ContentSpec (with data)

#    + 2 # get_ContentSpec
#    + 2 # get_ContentSpecs_where
#    + 2 # get_ContentSpecs_ids_where
#    + 2 # get_ContentSpecs_fields_where

#    + 2 # delete_ContentSpec
#    + 2 # delete_ContentSpecs
;

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

use SLight::API::ContentSpec qw(
    add_ContentSpec
);

SLight::Core::DB::check();

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
        version       => 0,

        _data => {
            label => {
                datatype => q{},
                caption  => q{},

                order => 1,

                default    => q{},
                max_length => 128,

                translate => 1,
                optional  => 0,

                display_on_page => 1,
                display_on_list => 1,
                display_label   => 1,
            },
            summary => {
                datatype => q{},
                caption  => q{},

                order => 1,

                default    => q{},
                max_length => 128,

                translate => 1,
                optional  => 0,

                display_on_page => 1,
                display_on_list => 1,
                display_label   => 1,
            },
        }
    ),
    2,
    'add_ContentSpec (2/4)'
);
is (
    $t2 = add_ContentSpec(
        caption       => 'Paintball gun',
        owning_module => 'CMS::Entry',

        _data => {
            brand => {
            },
            model => {
            },
            bps => {
            },
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

        _data => {
            name => {
            },
            chest_size => {
            },
            waist_size => {
            },
            hips_size => {
            },
            cup_size => {
            },
        },
    ),
    4,
    'add_ContentSpec (4/4)'
);

exit(); # SLight ends here!

ok (
    SLight::API::ContentSpec::set_one(
        caption => 'Paintball gun',
        status  => 'visible',
        fields  => {
            marker => {
                caption    => 'Marker Brand',
                datatype   => 'String',
                default    => '',
                translate  => 0,
                display    => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            balls  => {
                caption   => 'Paintballs',
                datatype  => 'String',
                default   => '',
                translate => 0,
                display   => 1,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            air    => {
                caption   => 'Gass type',
                datatype  => 'String',
                default   => 'HP',
                translate => 1,
                display   => 2,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            bps    =>{
                caption   => 'Balls Per Second',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
        },
        fields_order => [qw{ marker bps air balls }],
        role => {
            'title' => 'marker',
            'sort'  => 'bps',
        }
    ),
    'set_one - adding'
);
ok (
    SLight::API::ContentSpec::set_one(
        caption => 'Woman',
        status  => 'hidden',
        fields  => {
            chest => {
                caption   => 'Chest',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            waist => {
                caption   => 'Waist',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            hips  => {
                caption   => 'Hips',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
        },
        fields_order => [qw{ chest waist hips }],
        role => {
            'title' => '',
            'sort'  => '',
        }
    ),
    'set_one - adding another'
);
ok (
    SLight::API::ContentSpec::set_one(
        id      => 2,
        caption => 'Beautifull łoman', # Ł sounds in polish similarry to english 'w' 
        status  => 'hidden',
        fields  => {
            tits => {
                caption   => 'Chest',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            waist => {
                caption   => 'Waist',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            hips  => {
                caption   => 'Hips',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            cup => {
                caption   => 'Cup size',
                datatype  => 'String',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
        },
        fields_order => [qw{ tits waist hips cup }],
        role => {
            'title' => '',
            'sort'  => 'cup',
        }
    ),
    'set_one - editing another'
);
ok (
    SLight::API::ContentSpec::set_one(
        id      => 2,
        caption => 'Beautifull łoman',
        status  => 'hidden',
        fields  => {
            chest => {
                caption   => 'Chest',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            waist => {
                caption   => 'Waist',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            hips  => {
                caption   => 'Hips',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            cup => {
                caption   => 'Cup size',
                datatype  => 'String',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
        },
        fields_order => [qw{ chest waist hips cup }],
        role => {
            'title' => '',
            'sort'  => 'cup',
        }
    ),
    'set_one - nothign needed'
);

is_deeply (
    { SLight::API::ContentSpec::get_one( id => 1 ) },
    {
        id      => 1,
        caption => 'Paintball gun',
        status  => 'visible',
        fields  => {
            marker => {
                caption   => 'Marker Brand',
                datatype  => 'String',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            balls  => {
                caption   => 'Paintballs',
                datatype  => 'String',
                default   => '',
                translate => 0,
                display   => 1,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            air    => {
                caption   => 'Gass type',
                datatype  => 'String',
                default   => 'HP',
                translate => 1,
                display   => 2,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            bps    =>{
                caption   => 'Balls Per Second',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
        },
        fields_order => [qw{ marker bps air balls }],
        role => {
            'title' => 'marker',
            'sort'  => 'bps',
        }
    },
    'Get a Paintball gun (hash context)'
);
is_deeply (
    scalar SLight::API::ContentSpec::get_one( id => 2 ),
    {
        id      => 2,
        caption => 'Beautifull łoman',
        status  => 'hidden',
        fields  => {
            chest => {
                caption   => 'Chest',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            waist => {
                caption   => 'Waist',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            hips  => {
                caption   => 'Hips',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            cup => {
                caption   => 'Cup size',
                datatype  => 'String',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
        },
        fields_order => [qw{ chest waist hips cup }],
        role => {
            'title' => 'chest', # This was set to '', but get_one will return first field from fields_order
            'sort'  => 'cup',
        }
    },
    'Get a Beautifull woman (scalar context)'
);

my $list = [
    {
        id      => 1,
        caption => 'Paintball gun',
        status  => 'visible',
        fields  => {
            marker => {
                caption   => 'Marker Brand',
                datatype  => 'String',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            balls  => {
                caption   => 'Paintballs',
                datatype  => 'String',
                default   => '',
                translate => 0,
                display   => 1,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            air    => {
                caption   => 'Gass type',
                datatype  => 'String',
                default   => 'HP',
                translate => 1,
                display   => 2,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            bps    =>{
                caption   => 'Balls Per Second',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
        },
        fields_order => [qw{ marker bps air balls }],
        role => {
            'title' => 'marker',
            'sort'  => 'bps',
        }
    },
    {
        id      => 2,
        caption => 'Beautifull łoman',
        status  => 'hidden',
        fields  => {
            chest => {
                caption   => 'Chest',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            waist => {
                caption   => 'Waist',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            hips  => {
                caption   => 'Hips',
                datatype  => 'Int',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
            cup => {
                caption   => 'Cup size',
                datatype  => 'String',
                default   => '',
                translate => 0,
                display   => 0,
                use_label  => 0,
                optional   => 0,
                max_length => 64,
            },
        },
        fields_order => [qw{ chest waist hips cup }],
        role => {
            'title' => 'chest',
            'sort'  => 'cup',
        }
    },
];

is_deeply (
    [ SLight::API::ContentSpec::get_list( ) ],
    $list,
    'get_list in list context'
);
is_deeply (
    scalar SLight::API::ContentSpec::get_list( ),
    $list,
    'get_list in scalar context'
);

ok ( SLight::API::ContentSpec::del_one( id=>2 ), 'del_one - no woman');
is_deeply (
    scalar SLight::API::ContentSpec::get_list( ),
    [
        {
            id      => 1,
            caption => 'Paintball gun',
            status  => 'visible',
            fields  => {
                marker => {
                    caption   => 'Marker Brand',
                    datatype  => 'String',
                    default   => '',
                    translate => 0,
                    display   => 0,
                    use_label  => 0,
                    optional   => 0,
                    max_length => 64,
                },
                balls  => {
                    caption   => 'Paintballs',
                    datatype  => 'String',
                    default   => '',
                    translate => 0,
                    display   => 1,
                    use_label  => 0,
                    optional   => 0,
                    max_length => 64,
                },
                air    => {
                    caption   => 'Gass type',
                    datatype  => 'String',
                    default   => 'HP',
                    translate => 1,
                    display   => 2,
                    use_label  => 0,
                    optional   => 0,
                    max_length => 64,
                },
                bps    =>{
                    caption   => 'Balls Per Second',
                    datatype  => 'Int',
                    default   => '',
                    translate => 0,
                    display   => 0,
                    use_label  => 0,
                    optional   => 0,
                    max_length => 64,
                },
            },
            fields_order => [qw{ marker bps air balls }],
            role => {
                'title' => 'marker',
                'sort'  => 'bps',
            }
        },
    ],
    'del_one check - no woman, no cry :)'
);
    
# vim: fdm=marker
