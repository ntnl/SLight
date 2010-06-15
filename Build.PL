#!/usr/bin/perl
# Copyright 2010, Bartłomiej Syguła (natanael@natanael.krakow.pl)
#
# This is free software. It is licensed, and can be distributed under the same terms as Perl itself.
#
# For more, see my website: http://www-slight-cms.org/
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

        'FindBin'    => '1.47',
    },
    build_requires => {
        'Test::Exception'      => '0.27',
        'Test::FileReferenced' => '0.01',
        'Test::More'           => '0.94',
    },

    # Play nice with friends ;)
    create_makefile_pl => 'traditional',
    create_packlist    => 1,
    create_readme      => 1,
    dynamic_config     => 0, # No dynamics needed, as of now.
);

$build->create_build_script;

# vim: fdm=marker
