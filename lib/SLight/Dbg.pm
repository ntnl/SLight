package SLight::Dbg;
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

my $VERSION = '0.0.5';
# }}}

our @EXPORT_OK = qw(
    Dmp
    mDmp
);
our @EXPORT = @EXPORT_OK; ## no critic (ProhibitAutomaticExportation)
# Note: The whole purpose of this module it to make Dmp and mDmp available
# with minimal effort, hence the 'no critic' directive.

our %EXPORT_TAGS = (
    'all' => [ @EXPORT_OK ],
);

# Purpose:
#   SLight Diagnostics and Debug utility module.

# Purpose:
#   Data::Dump given parameters.
sub Dmp { # {{{
    my ( @stuff ) = @_;

    require Data::Dumper;

    printf STDERR qq{%s\n\@%s\n}, Data::Dumper::Dumper(@stuff), caller;

    return;
} # }}}

sub mDmp { # {{{
    my ( $msg, @stuff ) = @_;

    require Data::Dumper;

    printf STDERR qq{%s:\n%s\n\@%s\n}, $msg, Data::Dumper::Dumper(@stuff), caller;

    return;
} # }}}

# vim: fdm=marker
1;
