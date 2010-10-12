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

use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use SLight::Test::Site;

use English qw( -no_match_vars );
use File::Slurp qw( read_file );
use Digest::MD5::File qw( file_md5_hex );
use Test::More;
use Test::Exception;
# }}}

plan tests =>
	+ 8 # add_Asset
    + 2 # attach_Asset_to_Content
    + 2 # attach_Asset_to_Content_Field
    + 1 # get_Asset_ids_on_Content
    + 2 # get_Asset_ids_on_Content_Field
    + 1 # get_Asset_ids_on_Content_Fields
    + 2 # get_Asset
    + 1 # get_Assets
    + 2 # get_Asset_data
    + 2 # delete_Asset
    + 1 # delete_Assets
;

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Minimal'
);

# Note to self: must make a fake site with content.

use SLight::API::Asset qw(
	add_Asset
    attach_Asset_to_Content
    attach_Asset_to_Content_Field
    get_Asset_ids_on_Content
    get_Asset_ids_on_Content_Field
    get_Asset_ids_on_Content_Fields
    get_Asset
    get_Assets
    get_Asset_data
    delete_Asset
    delete_Assets
);

my $image_png = read_file($Bin .q{/../SampleImage.png});
my $image_jpg = read_file($Bin .q{/../SampleImage.jpg});
my $image_gif = read_file($Bin .q{/../SampleImage.gif});

my $md5_png = file_md5_hex($Bin .q{/../SampleImage.png});
my $md5_jpg = file_md5_hex($Bin .q{/../SampleImage.jpg});
my $md5_gif = file_md5_hex($Bin .q{/../SampleImage.gif});

my ($a1, $a2, $a3, $a4) = (1, 2, 3, 4);

################################################################################
#           Add Assets and attach them to Content Entities
################################################################################
is (
    add_Asset (
        data => $image_png,

        email => q{png@test.test},

        filename => 'SampleImage.png',
        summary  => 'Sample image: png',
    ),
    $a1,
    'put_attachment: to object'
);
ok ( attach_Asset_to_Content($a1, 1), 'attach_Asset_to_Content (1/2)');
is ( file_md5_hex( SLight::API::Asset::_path_for_id($a1) ), $md5_png, 'MD5 check');
is (
    add_Asset (
        data => $image_jpg,

        email => q{jpg@test.test},

        filename => 'SampleImage.jpg',
        summary  => 'Sample image: jpg',
    ),
    $a2,
    'put_attachment: to object - add another'
);
ok ( attach_Asset_to_Content($a2, 1), 'attach_Asset_to_Content (2/2)');
is ( file_md5_hex( SLight::API::Asset::_path_for_id($a2) ), $md5_jpg, 'MD5 check');
is (
    add_Asset (
        data => $image_jpg,

        email => q{jpg@test.test},

        filename => 'SampleImage.jpg',
        summary  => 'Sample image: jpg',
    ),
    $a3,
    'put_attachment: to field'
);
ok ( attach_Asset_to_Content_Field($a3, 1, 10), 'attach_Asset_to_Content_Field (1/2)');
is ( file_md5_hex( SLight::API::Asset::_path_for_id($a3) ), $md5_jpg, 'MD5 check');
is (
    add_Asset (
        data => $image_gif,

        email => q{gif@test.test},

        filename => 'SampleImage.gif',
        summary  => 'Sample image: gif',
    ),
    $a4,
    'put_attachment: to field - replace old one'
);
ok ( attach_Asset_to_Content_Field($a4, 1, 11), 'attach_Asset_to_Content_Field (2/2)');
is ( file_md5_hex( SLight::API::Asset::_path_for_id($a4) ), $md5_gif, 'MD5 check');

################################################################################
#                           get_* function tests
################################################################################

is_deeply(
    get_Asset_ids_on_Content(1),
    [ $a1, $a2 ],
    'get_Asset_ids_on_Content'
);

is_deeply(
    get_Asset_ids_on_Content_Field(1, 10),
    [ $a3 ],
    'get_Asset_ids_on_Content_Field',
);

is_deeply(
    get_Asset_ids_on_Content_Field(1, 11),
    [ $a4 ],
    'get_Asset_ids_on_Content_Field',
);

is_deeply(
    get_Asset_ids_on_Content_Fields(1),
    [ $a3, $a4 ],
    'get_Asset_ids_on_Content_Fields',
);

my $d1 = get_Asset($a1);
$d1->{'path'}  =~ s{$site_root}{FAKE/};
$d1->{'thumb'} =~ s{$site_root}{FAKE/};
is_deeply(
    $d1,
    {
        'id' => $a1,

        'filename' => 'SampleImage.png',
        'summary'  => 'Sample image: png',

#        'email' => q{png@test.test},

        'mime_type' => 'image/png',
        'byte_size' => '13379',

        'path'  => 'FAKE/assets/01/1.bin',
        'thumb' => 'FAKE/assets/01/1-thumb.png',
    },
    'get_Asset (1/2)',
);
my $d3 = get_Asset($a3);
$d3->{'path'}  =~ s{$site_root}{FAKE/};
$d3->{'thumb'} =~ s{$site_root}{FAKE/};
is_deeply(
    $d3,
    {
        'id' => $a3,

        'filename' => 'SampleImage.jpg',
        'summary'  => 'Sample image: jpg',

#        'email' => q{jpg@test.test},

        'mime_type' => 'image/jpeg',
        'byte_size' => '2543',

        'path'  => 'FAKE/assets/03/3.bin',
        'thumb' => 'FAKE/assets/03/3-thumb.png',
    },
    'get_Asset (2/2)',
);

my $assets = get_Assets( [ $a1, $a3 ] );
$assets->[0]->{'path'}  =~ s{$site_root}{FAKE/};
$assets->[0]->{'thumb'} =~ s{$site_root}{FAKE/};
$assets->[1]->{'path'}  =~ s{$site_root}{FAKE/};
$assets->[1]->{'thumb'} =~ s{$site_root}{FAKE/};
is_deeply(
    $assets,
    [
        {
            'id' => $a1,

            'filename' => 'SampleImage.png',
            'summary'  => 'Sample image: png',

#            'email' => q{png@test.test},

            'mime_type' => 'image/png',
            'byte_size' => '13379',

            'path'  => 'FAKE/assets/01/1.bin',
            'thumb' => 'FAKE/assets/01/1-thumb.png',
        },
        {
            'id' => $a3,

            'filename' => 'SampleImage.jpg',
            'summary'  => 'Sample image: jpg',

#            'email' => q{jpg@test.test},

            'mime_type' => 'image/jpeg',
            'byte_size' => '2543',

            'path'  => 'FAKE/assets/03/3.bin',
            'thumb' => 'FAKE/assets/03/3-thumb.png',
        },
    ],
    'get_Assets'
);

is ( get_Asset_data($a1), $image_png, q{get_Asset_data (1/2)});
is ( get_Asset_data($a3), $image_jpg, q{get_Asset_data (2/2)});

################################################################################
#           delete_* function tests
################################################################################

delete_Asset($a3);
is_deeply(
    get_Asset_ids_on_Content_Field(1),
    [ ],
    'delete_Asset works'
);
is (delete_Asset(123456), undef, 'delete_Asset works (on non-existing ID)');

delete_Assets( [ $a2, $a4 ] );
is_deeply(
    get_Assets( [ $a2, $a4 ] ),
    [],
    'delete_Assets works'
);

# vim: fdm=marker
