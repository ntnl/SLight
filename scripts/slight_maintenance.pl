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
use lib $Bin . q{/../lib/};

use SLight::Maintenance::Daily;
# }}}

my $VERSION = '0.0.5';

# Enable or disable maintenance mode in SLight CMS.

exit main();

sub main { # {{{
    if ($ARGV[0] =~ m{on}is) {
        _enable();
    }
    elsif ($ARGV[0] =~ m{off}is) {
        _disable();
    }
    else {
        print "SLight Maintenance mode switcher.\n";
        print "\n";
        print "Usage:\n";
        print "\n";
        print "Enable maintenance mode:\n";
        print "  \$ ./slight_maintenance.pl on\n";
        print "\n";
        print "Disable maintenance mode:\n";
        print "  \$ ./slight_maintenance.pl off\n";
        print "\n";
        print "This is version $VERSION of SLight.\n";
    }

    return 0;
} # }}}

# vim: fdm=marker
