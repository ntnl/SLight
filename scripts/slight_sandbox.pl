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
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin. '/../lib/';

use SLight::Test::Site;

use Carp::Assert::More qw( assert_defined assert_is assert_like );
use File::Copy::Recursive qw( dircopy );
use File::Path qw( remove_tree );
# }}}

my $site = ( $ARGV[0] or 'Minimal' );
my $dst_dir = ( $ARGV[1] or 'sandbox' );

assert_like($site, qr{^[A-Z][A-Za-z0-9]+$}s, "Site name OK.");

my $source      = $Bin . q{/../t_data/} . $site . q{/};
my $destination = $Bin . q{/../} . $dst_dir . q{/};

assert_is(-d $source,      1, "Source existst: $source");
assert_is(-d $destination, 1, "Destination exists: $destination");

print "Clearing $destination\n";

remove_tree($destination, { keep_root=>1 } );

print "Copying $source to $destination\n";

dircopy($source, $destination);

SLight::Test::Site::undump_db($destination);

print "Done\n";

# vim: fdm=marker
