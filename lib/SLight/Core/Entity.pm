package SLight::Core::Entity;
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

use SLight::Core::DB;

use Params::Validate qw( :all );
# }}}

=head1 Entity API schema

Following interface should be exported by all Entity API modules:

 $id = add_ENTITY(
     field_1 => $value_1,
     field_2 => $value_2,
     ...
     field_n => $value_n,
 )

 update_ENTITY (
     id => $id,
 
     field_1 => $value_1,
     field_2 => $value_2,
     ...
     field_n => $value_n,
 )

 update_ENTITYs (
     id => \@id,
 
     field_1 => $value_1,
     field_2 => $value_2,
     ...
     field_n => $value_n,
 )

 delete_ENTITY($id)

 delete_ENTITYs(\@ids)

 \%entity = get_ENTITY($id)

 \@entities => get_ENTITYs(\@ids)

 \@entities => get_ENTITYs_where(
     field_1 => $value_1,
     field_2 => $value_2,
     ...
     field_n => $value_n,
 )

 \@ids => get_ENTITY_ids_where(
     field_1 => $value_1,
     field_2 => $value_2,
     ...
     field_n => $value_n,
 )

 \@entities => get_ENTITY_fields_where(
     _fields => \@fields,
 
     field_1 => $value_1,
     field_2 => $value_2,
     ...
     field_n => $value_n,
 )

 attach_ENTITY_to_ENTITY($id, $to_id, $to_field)

 attach_ENTITYs_to_ENTITY(\@ids, $to_ids, $to_field)

=cut

# vim: fdm=marker
1;
