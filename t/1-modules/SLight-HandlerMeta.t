#!/usr/bin/perl
################################################################################
# 
# SLight - Lightweight Content Management System.
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
use lib $Bin . q{/../../lib/};

use SLight::Test::Site;

use English qw( -no_match_vars );
use File::Slurp qw( read_file );
use Digest::MD5::File qw( file_md5_hex );
use Test::More;
use Test::Exception;
# }}}

plan tests =>
    + 2 # get_handlers_list - all configured handlers exist.
;

use SLight::HandlerMeta;

my $handlers_list = SLight::HandlerMeta::get_handlers_list();

is (ref $handlers_list, 'ARRAY', q{get_handlers_list() returns array});

FAMILY: foreach my $family (@{ $handlers_list }) {
    foreach my $object (@{ $family->{'objects'} }) {
        foreach my $action (@{ $object->{'actions'} }) {
            my $module_path = q{SLight/Handler/}. $family->{'class'} .q{/}. $object->{'class'} .q{/}. $action .q{.pm};
            if (not require $module_path) {
                fail(q{get_handlers_list() has ghost (} . $module_path . q{)});
                last FAMILY;
            }
        }
    }
}
pass(q{get_handlers_list() lists only exisging handlers});

# vim: fdm=marker
