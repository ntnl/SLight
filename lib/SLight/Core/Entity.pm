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

use Carp::Assert::More qw( assert_positive_integer );
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

# Purpose:
#   Create and return handler object for some entities.
sub new { # {{{
    my ( $class, %P ) = @_;

    my $self = {
        base_table  => $P{'base_table'},
        field_table => $P{'child_table'},
            # Will be undef, if the table has no fields

        is_a_tree => $P{'is_a_tree'},

        has_metadata => $P{'has_metadata'},
            # Rows from main table contain 'metadata' column

        is_signed => $P{'is_signed'},
            # Rows from main table are signed with Email_id

        data_fields => $P{'data_fields'}
            # Other (not natively supported) data fields.
    };

    $self->{'_all_fields'} = [ @{ $P{'data_fields'} } ];
    if ($self->{'is_a_tree'}) {
        push @{ $self->{'_all_fields'} }, 'parent_id';
    }
    if ($self->{'has_metadata'}) {
        push @{ $self->{'_all_fields'} }, 'metadata';
    }
    
    $self->{'_really_all_fields'} = [ 'id', @{ $self->{'_all_fields'} } ];

    bless $self, $class;

    return $self;
} # }}}

sub add_ENTITY { # {{{
    my ( $self, %P ) = @_;

#    my %values;
#    foreach my $field (@{ $self->{'_all_fields'} }) {
#        $values{$field} = $P{$field};
#    }

    SLight::Core::DB::check();

    SLight::Core::DB::run_insert(
        'into'   => $self->{'base_table'},
        'values' => \%P,
#        debug    => 1, 
    );

    return SLight::Core::DB::last_insert_id();
} # }}}

sub update_ENTITY { # {{{
    my ( $self, %P ) = @_;

    assert_positive_integer($P{'id'});

    my %values;
    foreach my $field (@{ $self->{'_all_fields'} }) {
        if ($P{$field}) {
            $values{$field} = $P{$field};
        }
    }

    SLight::Core::DB::check();

    SLight::Core::DB::run_update(
        'table' => $self->{'base_table'},
        'set'   => \%values,
        'where' => [
            'id = ', $P{'id'},
        ],
#        debug => 1, 
    );

    return;
} # }}}

sub update_ENTITYs { # {{{
    my ( $self, %P ) = @_;

    my %values;
    foreach my $field (@{ $self->{'_all_fields'} }) {
        if ($P{$field}) {
            $values{$field} = $P{$field};
        }
    }

    SLight::Core::DB::check();

    SLight::Core::DB::run_update(
        'table' => $self->{'base_table'},
        'set'   => \%values,
        'where' => [
            'id IN ', $P{'ids'},
        ],
#        debug => 1, 
    );

    return;
} # }}}

sub get_ENTITY { # {{{
    my ( $self, $id ) = @_;

    assert_positive_integer($id);

    SLight::Core::DB::check();

    my $sth = SLight::Core::DB::run_select(
        columns => $self->{'_really_all_fields'},
        from    => $self->{'base_table'},
        where   => [ 'id = ', $id ],
#        debug => 1
    );
    
    return $sth->fetchrow_hashref();
} # }}}

sub get_ENTITYs { # {{{
    my ( $self, $ids ) = @_;

    SLight::Core::DB::check();

    my $sth = SLight::Core::DB::run_select(
        columns => $self->{'_really_all_fields'},
        from    => $self->{'base_table'},
        where   => [ 'id IN ', $ids ],
#        debug => 1
    );

    my @entities;
    while (my $entity = $sth->fetchrow_hashref()) {
        push @entities, $entity;
    }
    return \@entities;
} # }}}

sub count_ENTITYs_where { # {{{
    my ( $self, %P ) = @_;
    
    # YES, this IS stupid, but should work... will refactor later.

    my $where = $self->_make_where(%P);

    my $sth = SLight::Core::DB::run_select(
        columns => [ 'id' ],
        from    => $self->{'base_table'},
        where   => $where,
#        debug => 1
    );

    my @entity_ids;
    while (my ( $id ) = $sth->fetchrow_array()) {
        push @entity_ids, $id;
    }
    return scalar @entity_ids;
} # }}}

sub get_ENTITY_ids_where { # {{{
    my ( $self, %P ) = @_;
    
    my $where = $self->_make_where(%P);

    my $sth = SLight::Core::DB::run_select(
        columns => [ 'id' ],
        from    => $self->{'base_table'},
        where   => $where,
#        debug   => 1
    );

    my @entity_ids;
    while (my ( $id ) = $sth->fetchrow_array()) {
        push @entity_ids, $id;
    }
    return \@entity_ids;
} # }}}

sub get_ENTITY_fields_where { # {{{
    my ( $self, %P ) = @_;

    SLight::Core::DB::check();

    my $where = $self->_make_where(%P);

    my $sth = SLight::Core::DB::run_select(
        columns => $P{'_fields'},
        from    => $self->{'base_table'},
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
    my ( $self, %P ) = @_;

    my @where;
    my $glue = q{};
    foreach my $field (@{ $self->{'_all_fields'} }) {
        if (exists $P{$field}) {
            push @where, $glue . $field . q{ = }, $P{$field};

            $glue = ' AND ';
        }
    }

    return \@where;
} # }}}

sub delete_ENTITYs { # {{{
    my ( $self, $ids ) = @_;

    my $deleted_count = scalar @{ $ids };

    SLight::Core::DB::check();

    if ($self->{'is_a_tree'}) {
        # Get childs...
        my $sth = SLight::Core::DB::run_select(
            columns => [qw( id )],
            from    => $self->{'base_table'},
            where   => [ 'parent_id IN ', $ids ],
        );
        my @child_ids;
        while (my ( $child_id ) = $sth->fetchrow_array()) {
            push @child_ids, $child_id;
        }
        if (scalar @child_ids) {
            $deleted_count += $self->delete_ENTITYs(\@child_ids, $self->{'base_table'});
        }
    }

    SLight::Core::DB::run_delete(
        from  => $self->{'base_table'},
        where => [ 'id IN ', $ids ],
    );

    return $deleted_count;
} # }}}

# vim: fdm=marker
1;
