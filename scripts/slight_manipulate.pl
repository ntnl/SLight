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
use lib $Bin. '/../lib/';

my $VERSION = '0.0.3';

use SLight::Maintenance::Manipulate;
# }}}

=head1 NAME

F<slight_manipulate> - SLight command line interface tool.

=head1 SYNOPSIS

 $ slight_manipulate --cms-list /Foo/ --format json
 
 $ slight_manipulate --cms-delete /Foo/
 
 $ slight_manipulate --cms-set /Foo/ --input foo.xml

=head1 DESCRIPTION

Allows one to do certain tasks with SLight site database.
This includes, but may not be limited to:

=over

=item List CMS entries.

=item Delete CMS entries.

=item Add or update CMS entries.

=item Attach files to CMS entities.

=back

=head2 Supported data formats

Depending on what optional modules are installed, the following data formats are supported:

=over

=item XMS

Requires: L<XML::Smart>.

=item JSON

Requires L<JSON::Any>, that provide interface to one of: L<JSON>, L<JSON::Syck> or L<JXON::XS>.

=item YAML

Requires L<YAML::Any>, that provide interface to one of: L<YAML>, L<YAML::Syck> or L<YAML::XS>.

=back

=cut

exit SLight::Maintenance::Manipulate::main(@ARGV);

# vim: fdm=marker
