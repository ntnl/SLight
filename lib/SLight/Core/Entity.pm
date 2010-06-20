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

sub add_ENTITY { # {{{
    my %P = @_;

    my %values;
    foreach my $field (@{ $P{'_fields'} }) {
        $values{$field} = $P{$field};
    }

    SLight::Core::DB::check();

    SLight::Core::DB::run_insert(
        'into'   => $P{'_table'},
        'values' => \%values,
    );

    return SLight::Core::DB::last_insert_id();
} # }}}

sub update_ENTITY { # {{{
    my %P = @_;

    my %values;
    foreach my $field (@{ $P{'_fields'} }) {
        if ($P{$field}) {
            $values{$field} = $P{$field};
        }
    }

    SLight::Core::DB::check();

    SLight::Core::DB::run_update(
        'table' => $P{'_table'},
        'set'   => \%values,
        'where' => [
            'id = ', $P{'id'},
        ],
#        debug => 1, 
    );

    return;
} # }}}

sub update_ENTITYs { # {{{
    my %P = @_;

    my %values;
    foreach my $field (@{ $P{'_fields'} }) {
        if ($P{$field}) {
            $values{$field} = $P{$field};
        }
    }

    SLight::Core::DB::check();

    SLight::Core::DB::run_update(
        'table' => $P{'_table'},
        'set'   => \%values,
        'where' => [
            'id IN ', $P{'ids'},
        ],
#        debug => 1, 
    );

    return;
} # }}}

sub get_ENTITY { # {{{
    my ( $id, $table, $fields ) = @_;

    SLight::Core::DB::check();

    my $sth = SLight::Core::DB::run_select(
        columns => $fields,
        from    => $table,
        where   => [ 'id = ', $id ],
#        debug => 1
    );
    
    return $sth->fetchrow_hashref();
} # }}}

sub get_ENTITYs { # {{{
    my ( $ids, $table, $fields ) = @_;

    SLight::Core::DB::check();

    my $sth = SLight::Core::DB::run_select(
        columns => $fields,
        from    => $table,
        where   => [ 'id IN ', $ids ],
#        debug => 1
    );

    my @entities;
    while (my $entity = $sth->fetchrow_hashref()) {
        push @entities, $entity;
    }
    return \@entities;
} # }}}

sub get_ENTITY_ids_where { # {{{
    my %P = @_;
    
    my $where = _make_where(%P);

    my $sth = SLight::Core::DB::run_select(
        columns => [ 'id' ],
        from    => $P{'_table'},
        where   => $where,
#        debug => 1
    );

    my @entity_ids;
    while (my ( $id ) = $sth->fetchrow_array()) {
        push @entity_ids, $id;
    }
    return \@entity_ids;
} # }}}

sub get_ENTITY_fields_where { # {{{
    my %P = @_;

    SLight::Core::DB::check();

    my $where = _make_where(%P);

    my $sth = SLight::Core::DB::run_select(
        columns => $P{'_fields'},
        from    => $P{'_table'},
        where   => $where,
#        debug => 1
    );

    my @entities;
    while (my $entity = $sth->fetchrow_hashref()) {
        push @entities, $entity;
    }
    return \@entities;
} # }}}

sub _make_where { # {{{
    my %P = @_;

    my @where;
    my $glue = q{};
    foreach my $field (keys %P) {
        if ($field eq '_table') {
            next;
        }
        if ($field eq '_fields') {
            next;
        }

        push @where, $glue . $field . q{ = }, $P{$field};

        $glue = ' AND ';
    }

    return \@where;
} # }}}

sub delete_ENTITYs { # {{{
    my ( $ids, $table ) = @_;

    my $deleted_count = scalar @{ $ids };

    SLight::Core::DB::check();

    # Get childs...
    my $sth = SLight::Core::DB::run_select(
        columns => [qw( id )],
        from    => $table,
        where   => [ 'parent_id IN ', $ids ],
    );
    my @child_ids;
    while (my ( $child_id ) = $sth->fetchrow_array()) {
        push @child_ids, $child_id;
    }
    if (scalar @child_ids) {
        $deleted_count += delete_ENTITYs(\@child_ids, $table);
    }

    SLight::Core::DB::run_delete(
        from  => $table,
        where => [ 'id IN ', $ids ],
    );

    return $deleted_count;
} # }}}

# vim: fdm=marker
1;
