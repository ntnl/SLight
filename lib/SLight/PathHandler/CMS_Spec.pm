package SLight::PathHandler::CMS_Spec;
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
use base q{SLight::PathHandler};

my $VERSION = '0.0.4';

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

=item /_CMS_Spec/Field/$Spec_ID/$Field_CLASS/*

Generates a page with single I<SLight::Handler::CMS::SpecField::*> primary object.

=back

=cut

sub analyze_path { # {{{
    my ( $self, $path ) = @_;
    
    assert_defined($path, "Path is defined");

    $self->set_template('Default');

    $self->set_breadcrumb_path([]);

    if (scalar @{ $path }) {
        # OK... so We're actually showing something...
        if ($path->[0] eq 'Spec') {
            $self->do_spec($path->[1]);
        }
        elsif ($path->[0] eq 'Field') {
            $self->do_field($path->[1], $path->[2]);
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
        _spec => {
            class => 'CMS::Spec',
            oid   => $id,
        },
    );
    my @field_id_order;

    if ($id) {
        my $content_spec = SLight::API::ContentSpec::get_ContentSpec($id);

#        use Data::Dumper; warn "Content Spec: " . Dumper $content_spec;

        $objects{_spec}->{'metadata'}->{'spec'} = $content_spec;

        foreach my $field (sort {$content_spec->{'_data'}->{$a}->{'field_index'} <=> $content_spec->{'_data'}->{$b}->{'field_index'}} keys %{ $content_spec->{'_data'} }) {
            push @field_id_order, $field;
    
            $objects{$field} = {
                class    => 'CMS::SpecField',
                oid      => $field,
                metadata => {
                    spec => $content_spec,
                }
            };
        }
    }

#    $self->D_Dump($content_spec);

    $self->set_objects( \%objects );

    $self->set_object_order( [ '_spec', @field_id_order ] );

    $self->set_main_object('_spec');

#    use Data::Dumper; warn "Order and objects: " . Dumper \@field_id_order, \%objects;

    return;
} # }}}

# Purpose:
#   Handle field.
sub do_field { # {{{
    my ( $self, $spec_id, $field_class ) = @_;
    
    my $content_spec = SLight::API::ContentSpec::get_ContentSpec($spec_id);
    
    my %objects = (
        # TODO: Add 'CMS::Spec' as well, for reference!
        _field => {
            class    => 'CMS::SpecField',
            oid      => $field_class,
            metadata => {
                spec => $content_spec,
            }
        },
    );
    $self->set_objects( \%objects );

    $self->set_object_order( [ '_field' ] );

    $self->set_main_object('_field');

    return;
} # }}}

# vim: fdm=marker
1;
