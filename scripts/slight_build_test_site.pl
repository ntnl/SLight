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
use lib $Bin . '/../lib/';

use SLight::Test::Site::Builder;
# }}}

exit SLight::Test::Site::Builder::build_site(
    $Bin . q{/../t_data/},
    $Bin . q{/../sql/0.3/},
    sub { print @_, "\n"; },
    $ARGV[0],
);

# vim: fdm=marker

