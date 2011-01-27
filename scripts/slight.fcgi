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
use FCGI;
# }}}

if ($ENV{'SLIGHT_LIB'}) {
    push @INC, $ENV{'SLIGHT_LIB'};
}

# Fixme: this should be moved to it's own module

require SLight::Interface::CGI;

my $request = FCGI::Request();

while($request->Accept() >= 0) {
    my $interface = SLight::Interface::CGI->new();

    CGI::Minimal::reset_globals();

#    warn $ENV{'REQUEST_URI'};

    my $out = $interface->main(
        url => $ENV{'REQUEST_URI'},
        bin => $Bin,
    );

    utf8::encode($out);

    print $out;
}

# vim: fdm=marker

