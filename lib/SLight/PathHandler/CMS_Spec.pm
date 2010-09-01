package SLight::PathHandler::CMS_Spec;
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
use base q{SLight::PathHandler};

my $VERSION = '0.0.1';

use SLight::API::ContentSpec;

use Carp::Assert::More qw( assert_defined );
# }}}

=head1 DESCRPITION

This path handler supports the following path schemas:

=over

=item /_CMS_Spec/

Generates a page with single I<SLight::Handler::CMS::SpecList::*> object.

=item /_CMS_Spec/Spec/$ID/*

Generates a page with single I<SLight::Handler::CMS::Spec::*> primary object
and corresponding set of I<SLight::Handler::CMS::SpecField::Overview> aux objects.

=item /_CMS_Spec/Field/$ID/*

Generates a page with single I<SLight::Handler::CMS::SpecField::*> primary object.

=back

=cut

sub analyze_path { # {{{
    my ( $self, $path ) = @_;

    assert_defined($path, "Path is defined");


    return $self->response_content();
} # }}}

# vim: fdm=marker
1;
