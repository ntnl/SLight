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

        'CGI::Minimal'          => undef,
        'Carp::Assert::More'    => undef,
        'Carp'                  => undef,
        'Cwd'                   => undef,
        'DBI'                   => undef,
        'Data::Dumper'          => undef,
        'Data::UUID'            => undef,
        'Date::Calc'            => undef,
        'Digest::MD5'           => undef,
        'Digest::MD5::File'     => undef,
        'Digest::SHA'           => undef,
        'Encode'                => undef,
        'English'               => undef,
        'FCGI'                  => undef,
        'File::Basename'        => undef,
        'File::Copy::Recursive' => undef,
        'File::Path'            => undef,
        'File::Slurp'           => undef,
        'File::Spec'            => undef,
        'FindBin'               => '1.47',
        'Gravatar::URL'         => undef,
        'MIME::Lite'            => undef,
        'Module::Build'         => undef,
        'Params::Validate'      => undef,
        'Time::HiRes'           => undef,
        'URI::Escape'           => undef,
        'YAML::Syck'            => undef,
    },
    build_requires => {
        'Test::Exception'      => '0.27',
        'Test::FileReferenced' => '0.01',
        'Test::More'           => '0.94',
        'Test::Output'         => undef,
    },

    # Play nice with friends ;)
    create_makefile_pl => 'traditional',
    create_packlist    => 1,
    create_readme      => 1,
    dynamic_config     => 0, # No dynamics needed, as of now.
);

$build->create_build_script;

# vim: fdm=marker
