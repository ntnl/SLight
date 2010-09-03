package SLight::BaseClass;
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

my $VERSION = '0.0.1';

# }}}

# Purpose:
#   This suits as a base class for all SLight classes.
#   As such, it has some handy methods :)

# Purpose:
#   Data::Dump given parameters.
sub D_Dump { # {{{
    my ( $self, @stuff ) = @_;

    require Data::Dumper;

    warn Data::Dumper::Dumper(@stuff);

    return;
} # }}}

# vim: fdm=marker
1;
