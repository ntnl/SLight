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
use lib $Bin . q{/../lib/};
# }}}

if ($ENV{'SLIGHT_LIB'}) {
    push @INC, $ENV{'SLIGHT_LIB'};
}

require SLight::Interface::CGI;

my $interface = SLight::Interface::CGI->new();

print $interface->main(
    url => $ENV{'REQUEST_URI'},
    bin => $Bin,
);

# vim: fdm=marker
