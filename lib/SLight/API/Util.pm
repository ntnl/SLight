package SLight::API::Util;
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
use base 'Exporter';

use Params::Validate qw( :all );
# }}}

our @EXPORT_OK = qw(
    human_readable_size
);
our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

# Purpose:
#   Return human-readable size, eg turn:
#       128 => 128 B
#       1024 => 1.00 KB
#       1048576 => 1.00 MB
#   and so on...
sub human_readable_size { # {{{
    my ( $value ) = @_;

    if ($value >= 1_048_576) {
        return sprintf "%.2f MB", $value / 1_048_576;
    }
    elsif ($value >= 1_024) {
        return sprintf "%.2f KB", $value / 1_024;
    }

    return $value .q{ B};
} # }}}

# vim: fdm=marker
1;
