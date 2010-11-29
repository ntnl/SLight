package SLight::HandlerBase::CMS::Spec;
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
use base q{SLight::Handler};

use SLight::Core::L10N qw( TR TF );
# }}}

sub make_field_label { # {{{
    my ( $self, $content_spec, $field_id ) = @_;

    if ($field_id and $field_id =~ m{^\d+$}s) {
        # Numerical ID means data field ID.
        foreach my $field (values %{ $content_spec->{'_data'} }) {
            if ($field->{'id'} == $field_id) {
                return TF("Data field: %s", undef, $field->{'caption'});
            }
        }
    }

    if ($field_id) {
        # non-numerical ID means metadata field.
        return TR("Field: " . $field_id);
    }

    return TR('ID');
} # }}}

# vim: fdm=marker
1;
