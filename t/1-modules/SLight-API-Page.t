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
use FindBin qw{ $Bin };
use lib $Bin .'/../../lib/';

use SLight::Test::Site;

use English qw( -no_match_vars );
use Test::More;
# }}}

plan tests =>
    + 1 # add_page
    + 1 # update_page
    + 1 # update_pages
    + 1 # delete_page
    + 1 # delete_pages
    + 1 # get_page
    + 1 # get_pages
    + 1 # get_page_ids_where
    + 1 # get_page_fields_where
    + 1 # attach_page_to_page
    + 1 # attach_pages_to_page
;

use SLight::API::Page;

SLight::API::Page::run_test();

# vim: fdm=marker
