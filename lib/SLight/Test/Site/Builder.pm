package SLight::Test::Site::Builder;
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

use SLight::Core::Config;
use SLight::Core::DB;
use SLight::Maintenance::Install;
use SLight::Test::Site;

use Carp::Assert::More qw( assert_exists assert_defined assert_is );
use File::Path qw( remove_tree );
use File::Slurp qw( write_file );
# }}}

my %sites = (
    'Minimal' => [qw( Minimal )],
    'Users'   => [qw( Users )],
);

my $_site_root;

# Parameters:
#   base_dir - where to create the site's dir
#   name     - site's dir
sub build_site { # {{{
    my ( $base_dir, $sql_dir, $print_cb, $site_name ) = @_;

    assert_defined($site_name, "Site name defined.");
    assert_exists(\%sites, $site_name, "Site configured.");

    $_site_root = $base_dir . q{/}. $site_name;

    # Prepare directory by cleaning it from previous contents.
    remove_tree($_site_root, { keep_root=>1 } );

    # Initialize the directory.
    SLight::Maintenance::Install::make_site(
        $_site_root,
        $print_cb,
        $sql_dir,
    );

    SLight::Test::Site::fake_config($_site_root);

    # Run code, that will fill the site.
    my $module_path = q{SLight/Test/Site/} . $site_name . q{.pm};

    require $module_path;

    my $func = q{SLight::Test::Site::} . $site_name;

    $func->build();

    # Dump the database into text format (more portable)

    my $db_path   = $_site_root . q{/db/slight.sqlite};
    my $dump_path = $_site_root . q{/db/slight.dump};

    assert_is(-f $db_path, 1, "DB exists");

    system qq{sqlite3 $db_path .dump > $dump_path};

    unlink $db_path;

    return 0;
} # }}}

sub make_template { # {{{
    my ( $name, $contents ) = @_;

    my $html_dir = $_site_root . q{/html/};

    if (not -d $html_dir) {
        mkdir $html_dir;
    }

    write_file($html_dir . $name . q{.html}, $contents);

    return;
} # }}}

# vim: fdm=marker
1;