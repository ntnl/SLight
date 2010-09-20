package SLight::Test::Site::Builder::Test;
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

use SLight::Test::Site::Builder;

use Test::More;
use English qw( -no_match_vars );
# }}}

sub test_builder { # {{{
    my ( $base_dir, $sql_dir, $site_name ) = @_;

    plan tests =>
        + 1 # Check if the build runs at all...
        + 1 # DB was created...
    ;

    my $tmp_build_sandbox = q{/tmp/} . $PID .q{/};
    
    mkdir $tmp_build_sandbox;
    
    my $site_build_dir = $tmp_build_sandbox . $site_name . q{/};
    mkdir $site_build_dir;

    my @output;

    is (
        SLight::Test::Site::Builder::build_site($tmp_build_sandbox, $sql_dir, sub { push @output, \@_; }, $site_name),
        0,
        $site_name . q{ runs},
    );

    is (
        ( -f $site_build_dir . q{db/slight.dump} ),
        1,
        'slight.dump exists'
    );

    return;
} # }}}

# vim: fdm=marker
1;
