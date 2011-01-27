#!/usr/bin/perl
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
use strict; use warnings;

use Module::Build;
my $build = Module::Build->new (
    # Who I am :)
    module_name => 'SLight',
    license     => 'perl',

    dist_abstract => 'Light, yet feature-rich Content Management System',
    dist_author   => 'Bartłomiej Syguła <natanael@natanael.krakow.pl>',

    # What You must have, and what will do You good.
    requires => {
        'perl' => '5.8.0',

        'CGI::Minimal'          => '1.29',
        'Carp::Assert::More'    => '1.12',
        'DBI'                   => '1.616',
        'Data::Dumper'          => '2.120',
        'Data::UUID'            => '1.217',
        'Date::Calc'            => '6.3',
        'Digest::MD5'           => '2.51',
        'Digest::MD5::File'     => '0.07',
        'Digest::SHA'           => '5.50',
        'Encode'                => '2.39',
        'FCGI'                  => '0.71',
        'File::Path'            => '2.08',
        'File::Slurp'           => '9999.12',
        'FindBin'               => '1.47',
        'Gravatar::URL'         => '1.02',
        'MIME::Lite'            => '3.027',
        'Params::Validate'      => '0.95',
        'Time::HiRes'           => '1.9721',
        'URI::Escape'           => '1.58',
        'YAML::Syck'            => '1.17',
    },
    build_requires => {
        'Test::Exception'       => '0.27',
        'Test::FileReferenced'  => '0.01',
        'Test::More'            => '0.94',
        'Test::Output'          => '0.16',
        'File::Copy::Recursive' => '0.38',
    },

    # Play nice with friends ;)
    create_makefile_pl => 'traditional',
    create_packlist    => 1,
    create_readme      => 1,
    dynamic_config     => 0, # No dynamics needed, as of now.
);

$build->create_build_script;

# vim: fdm=marker
