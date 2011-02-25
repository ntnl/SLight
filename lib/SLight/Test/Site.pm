package SLight::Test::Site;
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
use utf8;

our $VERSION = 0.0.3;

use SLight::Core::Config;
use SLight::Core::DB;
use SLight::Core::Email;

#use SLight::Core::IO qw( drop_path_dots );
use SLight::Maintenance::Install;

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use File::Copy::Recursive qw( dircopy );
use File::Path qw( remove_tree );
use Params::Validate qw( :all );
# }}}

# May be used only from t/?-*/*.t tests!

my $SQL_VERSION = q{0.3};

my $test_dir;

# Interface:

# Prepare just the place in which fake site resides.
sub prepare_place { # {{{
    my %P = validate(
        @_,
        {
            test_dir => { type=>SCALAR },
        }
    );

    $test_dir = $P{'test_dir'};

    my $site_root = prepare_fake_dir();

    fake_config($site_root);

    return $site_root;
} # }}}

# Prepare an empty site.
sub prepare_empty { # {{{
    my %P = validate(
        @_,
        {
            test_dir => { type=>SCALAR },
        }
    );

    $test_dir = $P{'test_dir'};

    my $site_root = prepare_fake_dir();

    SLight::Maintenance::Install::make_site(
        $site_root,
        sub { my $msg = shift; print "# $msg\n"; },
        $test_dir .q{/../sql/} . $SQL_VERSION,
    );

    fake_config($site_root);

    return $site_root;
} # }}}

# Fake a site using pre-prepared data.
sub prepare_fake { # {{{
    my %P = validate(
        @_,
        {
            test_dir => { type=>SCALAR },
            site     => { type=>SCALAR },
        }
    );

    $test_dir = $P{'test_dir'};

    my $src_dir = $test_dir .q{/../t_data/}. $P{'site'};
    assert_defined(-d $src_dir, "Fake site ($src_dir) exist.");

    my $site_root = prepare_fake_dir();

    File::Copy::Recursive::dircopy(
        $src_dir,
        $site_root
    );

    # Turn SQLite Dump into DB.

    SLight::Test::Site::undump_db($site_root);

    fake_config($site_root);

    return $site_root;
} # }}}

# Internal subroutines.

# Turn SQLite Dump into DB.
sub undump_db { # {{{
    my ( $site_root ) = @_;

    my $fh;
    if (open $fh, q{-|}, q{sqlite3 -batch -init } . $site_root . q{/db/slight.dump } . $site_root . q{/db/slight.sqlite '/* */' 2>&1}) {
        while (my $msg = <$fh>) {
            print "# " . $msg;
        }
        close $fh;
    }

    return;
} # }}}

# Clear fake directory, so it contains nothing.
sub prepare_fake_dir { # {{{
    assert_defined($test_dir, "Test dir set up properly");

    SLight::Core::Config::initialize($test_dir);

    my $site_root = clear_fake();

    if (not -d $site_root) {
        mkdir $site_root;
    }
    
    return $site_root;
} # }}}

# Fake options in the configuration.
sub fake_config { # {{{
    my ( $site_root ) = @_;

    SLight::Core::Config::set_option('domain',    q{foo.localdomain});
    SLight::Core::Config::set_option('web_root',  q{/});
    SLight::Core::Config::set_option('site_root', $site_root);
    SLight::Core::Config::set_option('data_root', $site_root);
    SLight::Core::Config::set_option('lang',      [qw{ en de fr pl }]);

    # Connect to DB, for convenance.
    if (-f ($site_root . q{/db/slight.sqlite}) ) {
        SLight::Core::DB::check();
    };

    # Disable any emails from being sent!
    # Must be enabled explicitly, if this is desired in tests.
    SLight::Core::Email::debug_disable_sending();

    return $site_root;
} # }}}

sub clear_fake { # {{{
    assert_defined($test_dir, "Module initialized properly.");

    my $test_site_basedir = SLight::Core::Config::get_option(q{test_site_dir});
    assert_defined($test_site_basedir, q{Config option: 'test_site_dir' configured!});

    # Make sure, that it ALWAYS ends with '/'
    $test_site_basedir =~ s{/?$}{/}s;

    if (not -d $test_site_basedir) {
        mkdir $test_site_basedir;
    }

    my $fake_directory = $test_site_basedir . $PID .q{/};

    if (-d $fake_directory) {
        remove_tree( $fake_directory, { keep_root=>1 } );
    }

    return $fake_directory;
} # }}}

# vim: fdm=marker
1;
