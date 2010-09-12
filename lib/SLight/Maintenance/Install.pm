package SLight::Maintenance::Install;
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

our $VERSION = 0.0.1;

use Carp::Assert::More qw( assert_defined assert_is );

use Params::Validate qw( :all );
# }}}

# Create a bare, minimal, empty SLight site directory.
# Return true (1) if site was created with no problems.
# Throws an error, if there was a problem during site creation.
sub make_site { # {{{
    validate_pos(
        @_,
        { type=>SCALAR },
        { type=>CODEREF },
        { type=>SCALAR },
    );
    my ( $destination, $feedback_call, $sql_source ) = @_;

    assert_defined(-d $destination, "Destination directory is a directory.");

    # Make sure, that it ends with a slash.
    $destination =~ s{/?$}{/}s;
    $sql_source  =~ s{/?$}{/}s;

    $feedback_call->("Making empty SLight site in: ". $destination);
    $feedback_call->("SQL data fetched from: ". $sql_source);
    
#    use Carp; confess $sql_source;

    $feedback_call->("Making directories...");

    mkdir $destination .q{sessions};
    mkdir $destination .q{assets};
    mkdir $destination .q{users};
    mkdir $destination .q{cache};

    mkdir $destination .q{db};

    $feedback_call->("Making sqlites...");

    assert_is( -f $destination . q{db/slight.sqlite}, undef, "File: db/slight.sqlite does not exists.");
    # Fixme: this array should be filled automatically
    my @init_files = (
    	$sql_source . q{content.sql},
        $sql_source . q{auth.sql},
        $sql_source . q{cache.sql},
    );
    foreach my $file (@init_files) {
        assert_defined( -f $file, "Source file ($file) exists");

#        system q{sqlite3}, q{-init}, $file, $destination . q{db/slight.sqlite}, q{/* */};

        my $fh;
        if (open $fh, q{-|}, q{sqlite3 -init } . $file . q{ } . $destination . q{db/slight.sqlite '/* */' 2>&1}) {
            while (my $msg = <$fh>) {
                print "# " . $msg;
            }
            close $fh;
        }
    }

    $feedback_call->("All done.");

    return 1;
} # }}}

# vim: fdm=marker
1;
