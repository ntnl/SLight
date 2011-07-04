package SLight;
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

my $VERSION = '0.0.4';

# }}}

=encoding UTF-8

=head1 NAME

SLight - Lightweight Content Management System.

=head1 DESCRIPTION

SLight is a CMS written in Perl 5. At this stage, it is in development, and should not be used to run on 'production' websites.

You are welcome to browse the code, send comments and contributions!

=cut

sub version { # {{{
    return $VERSION;
} # }}}

# vim: fdm=marker
1;
