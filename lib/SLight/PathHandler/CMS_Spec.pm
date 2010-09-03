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

    $self->set_template('Default');

    if (scalar @{ $path }) {
        # OK... so We're actually showing something...
        if ($path->[0] eq 'Spec') {
            $self->do_spec($path->[1]);
        }
        elsif ($path->[0] eq 'Field') {
            $self->do_field($path->[1]);
        }
        else {
            # FIXME! Bad URL - must report this fact. Somehow.
        }
    }
    else {
        # Dump the list of known specs.
        $self->do_spec_list();
    }

    return $self->response_content();
} # }}}

# Purpose:
#   List specs available in system
sub do_spec_list { # {{{
    my ( $self ) = @_;

    $self->set_objects(
        {
            l1 => {
                class => 'CMS::SpecList',
                oid   => undef,
            },
        },
    );

    $self->set_object_order([qw( l1 )]);

    $self->set_main_object('l1');

    return;
} # }}}

# Purpose:
#   Handle specific spec ;) and outline his fields as aux data.
sub do_spec { # {{{
    my ( $self, $id ) = @_;

    my %objects = (
        s1 => {
            class => 'CMS::Spec',
            oid   => undef,
        },
    );
    my @field_id_order;

    my $content_spec = SLight::API::ContentSpec::get_ContentSpec($id);

#    $self->D_Dump($content_spec);

    $self->set_objects( \%objects );

    $self->set_object_order( [ 's1', @field_id_order ] );

    $self->set_main_object('s1');

    return;
} # }}}

# Purpose:
#   Handle field.
sub do_field { # {{{
    my ( $self, $id ) = @_;

    return;
} # }}}

# vim: fdm=marker
1;
