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
use SLight::Core::Cache qw( Cache_get Cache_put Cache_invalidate Cache_invalidate_referenced );

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

     _data => {
        $data_id_1 => \%value_1,
        $data_id_2 => \%value_2,
        ...
        $data_id_n => \%value_n,
     }
 )

 update_ENTITY (
     id => $id,
 
     field_1 => $value_1,
     field_2 => $value_2,
     ...
     field_n => $value_n,

     _data => {
        $data_id_1 => \%value_1,
        $data_id_2 => \%value_2,
        ...
        $data_id_n => \%value_n,
     },
     _data_field => $data_field, # if given, \%value_n should be replaced to $value_n
 )
    # To delete a '_data' item, set it's key to undef - and do not use '_data_field'.
    # If '_data_field' is used, and data item is undef, then the routine will put NULL in the coresponding column.
    #
    # Data items not given in '_data' hash are not altered - not updated, and not deleted - simply ignored.

 update_ENTITYs (
     id => \@id,
 
     field_1 => $value_1,
     field_2 => $value_2,
     ...
     field_n => $value_n,

     _data => {
        $data_id_1 => \%value_1,
        $data_id_2 => \%value_2,
        ...
        $data_id_n => \%value_n,
     },
     _data_field => $data_field, # if given, \%value_n should be replaced to $value_n
 )

 delete_ENTITY($id)

 delete_ENTITYs(\@ids)

 \%entity = get_ENTITY($id)

 %entity = (
     field_1 => $value_1,
     field_2 => $value_2,
     ...
     field_n => $value_n,

    _parent => {
        parent_field_1 => $parent_value_1,
        parent_field_2 => $parent_value_2,
        ...
        parent_field_n => $parent_value_n,
    },

    # Present, when '_child_field' is used:
    _$child_field => {
        $child_key_1 => $child_val_1,
        $child_key_2 => $child_val_2,
        ...
        $child_key_n => $child_val_n,
    },

     _data => {
        $data_id_1 => \%value_1,
        $data_id_2 => \%value_2,
        ...
        $data_id_n => \%value_n,
     }
 );

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

 \@entities => get_ENTITYs_fields_where(
     _fields        => \@fields,
     _data_field    => $field,
     _data_fields   => \@child_fields,
     _parent_fields => \@parent_fields
 
     field_1 => $value_1,
     field_2 => $value_2,
     ...
     field_n => $value_n,
 )

 attach_Comment_to_ENTITY($id, $to_id)

 attach_Comment_to_ENTITY(\@ids, $to_ids)

 attach_Asset_to_ENTITY($id, $to_id, $to_field)

 attach_Assets_to_ENTITY(\@ids, $to_ids, $to_field)

=cut

# Purpose:
#   Create and return handler object for some entities.
sub new { # {{{
    my ( $class, %P ) = @_;

    my $self = {
        base_table  => $P{'base_table'},

        child_table  => $P{'child_table'},
        parent_table => $P{'parent_table'},
            # Those might be undef, if the entity has no parents/childrens
            # Note: Email/User/Comment handling support is build-in, it does not have to be defined.

        is_a_tree => $P{'is_a_tree'},

        has_metadata => $P{'has_metadata'},
            # Rows from main table contain 'metadata' column

        has_comments => $P{'has_comments'},
            # The entity can have comments assigned to it.

        has_assets => $P{'has_comments'},
            # The entity can have assets assigned to it.

        has_owner => $P{'has_owner'},
            # Entity is owned by signing them with Email_id

        data_fields => $P{'data_fields'},
            # Other (not natively supported) data fields.

        child_data_fields  => $P{'child_data_fields'},
            # Data fields of parents records. Might be undef.

        child_key => $P{'child_key'},
            # Data fields of parents records. Might be undef.

        child_df_data_field => undef,

#        fetch_cb => $P{'get_cb'},
#        store_cb => $P{'put_cb'},
#            # Callbacks run when entries enter/leave the storage
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

# Notes to self :)
#
#
# Content Entity
# {
#   base_table   => 'Content_Entity',
#   child_table  => 'Content_Entity_Data',
#   parent_table => 'Content_Spec',
#
#   data_fields        => [qw( status comment_write_policy comment_read_policy added_time modified_time )],
#   child_data_fields  => [qw( language value )],
#   parent_data_fields => [qw( owning_module )],
#
#   child_key => 'Content_Spec_Field_id',
#
#   has_metadata => 1,
#   has_owner    => 1,
#   has_assets   => 1,
#   has_comments => 1,
# }
#
# Comment
# {
#   base_table => 'Comment_Entity',
#
#   data_fields        => [qw( added status title text )],
#
#   is_a_tree => 1,
#   has_owner    => 1,
#   has_assets   => 1,
# }
#
# User
# {
#   base_table => 'User_Entity',
#
#   data_fields => [qw( login status name pass_enc )],
#
#   has_metadata => 1,
#   has_owner    => 1,
#   has_assets   => 1,
#   has_comments => 1,
# }
#
# Email Verification Key (EVK)
# {
#   base_table => 'Email_Verification_Key',
#
#   data_fields => [qw( key handler params )],
#
#   has_owner => 1,
# }

sub add_ENTITY { # {{{
    my ( $self, %P ) = @_;

#    my %values;
#    foreach my $field (@{ $self->{'_all_fields'} }) {
#        $values{$field} = $P{$field};
#    }

    SLight::Core::DB::check();

    my $data_hash = delete $P{'_data'};

    SLight::Core::DB::run_insert(
        'into'   => $self->{'base_table'},
        'values' => \%P,
#        debug    => 1, 
    );

    my $entity_id = SLight::Core::DB::last_insert_id();

    if ($data_hash) {
        foreach my $field (keys %{ $data_hash }) {
            my $field_data = $data_hash->{$field};

            SLight::Core::DB::run_insert(
                'into'   => $self->{'child_table'},
                'values' => {
                    %{ $field_data },

                    $self->{'base_table'} . q{_id} => $entity_id,

                    $self->{'child_key'} => $field,
                },
#                debug    => 1, 
            );
        }
    }

    return $entity_id;
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

    my $data_hash = delete $P{'_data'};

    SLight::Core::DB::run_update(
        'table' => $self->{'base_table'},
        'set'   => \%values,
        'where' => [
            'id = ', $P{'id'},
        ],
#        debug => 1, 
    );

    if ($data_hash) {
        foreach my $field (keys %{ $data_hash }) {
            my $field_data = $data_hash->{$field};

            SLight::Core::DB::run_update(
                'table' => $self->{'child_table'},
                'set'   => $field_data,
                'where' => [
                    $self->{'base_table'} . q{_id = }, $P{'id'},

                    q{ AND } . $self->{'child_key'} . q{ = }, $field
                ],
#                debug => 1, 
            );
        }
    }

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
    
    my $entity = $sth->fetchrow_hashref();

    # Nothing found in DB? Exis ASAP...
    if (not $entity) {
        return;
    }

    if ($self->{'child_table'}) {
        $self->_add_data_to_entities( { $id => $entity } );
    }

    # Metadata field support.
    if ($self->{'has_metadata'}) {
        if ($entity->{'metadata'}) {
            $entity->{'metadata'} = Load($entity->{'metadata'});
        }
        else {
            $entity->{'metadata'} = {};
        }
    }

    return $entity;
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

sub get_ENTITYs_where { # {{{
    my ( $self, %P ) = @_;
    
    my $where = $self->_make_where(%P);

    my $sth = SLight::Core::DB::run_select(
        columns => $self->{'_really_all_fields'},
        from    => $self->{'base_table'},
        where   => $where,
#        debug   => 1
    );

    my %entities;
    while (my $entity = $sth->fetchrow_hashref()) {
        $entities{ $entity->{'id'} } = $entity;

        if ($self->{'has_metadata'}) {
            if ($entity->{'metadata'}) {
                $entity->{'metadata'} = Load($entity->{'metadata'});
            }
            else {
                $entity->{'metadata'} = {};
            }
        }
    }

    if (not scalar keys %entities) {
        return [];
    }

    if ($self->{'child_table'}) {
        $self->_add_data_to_entities(\%entities);
    }

#    use Data::Dumper; warn Dumper \%entities;

    return [ values %entities ];
} # }}}

# Note:
#   Function uses 'id' column internally, thus this column is returned, even if not asked for.
sub get_ENTITYs_fields_where { # {{{
    my ( $self, %P ) = @_;

    SLight::Core::DB::check();

    my %entities;
    my $where = $self->_make_where(%P);

    my %fields = map { $_ => 1 } @{ $P{'_fields'} or [] };
    $fields{'id'} = 1;

    my $sth = SLight::Core::DB::run_select(
        columns => [ keys %fields ],
        from    => $self->{'base_table'},
        where   => $where,
#        debug => 1
    );

    while (my $entity = $sth->fetchrow_hashref()) {
        $entity->{'id'};

        $entities{ $entity->{'id'} } = $entity;

        if ($self->{'has_metadata'} and $fields{'metadata'}) {
            if ($entity->{'metadata'}) {
                $entity->{'metadata'} = Load($entity->{'metadata'});
            }
            else {
                $entity->{'metadata'} = {};
            }
        }
    }

    if ($self->{'child_table'} and $P{'_data_fields'}) {
        $self->_add_data_to_entities( \%entities, $P{'_data_fields'} );
    }

    return [ values %entities ];
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

sub _add_data_to_entities { # {{{
    my ( $self, $entities, $fields ) = @_;

    my $sth = SLight::Core::DB::run_select(
        columns => [
            @{ $fields or $self->{'child_data_fields'} },

            $self->{'base_table'} . q{_id},
            $self->{'child_key'},
        ],
        from    => $self->{'child_table'},
        where   => [
            $self->{'base_table'} . q{_id IN }, [ keys %{ $entities } ]
        ],
#        debug => 1
    );

        while (my $row = $sth->fetchrow_hashref()) {
            my $key = delete $row->{ $self->{'child_key'} };
            my $eid = delete $row->{ $self->{'base_table'} . q{_id} };

            $entities->{$eid}->{'_data'}->{ $key } = $row;
        }

    return;
} # }}}

sub delete_ENTITY { # {{{
    my ( $self, $id ) = @_;

    # To refactor this, or not to refactor - this is the question?
    
    return $self->delete_ENTITYs( [$id] );
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
    
    # Before deleting main rows, thrit coresponding child rows must be deleted.
    if ($self->{'child_table'}) {
        SLight::Core::DB::run_delete(
            from  => $self->{'child_table'},
            where => [ $self->{'base_table'} . q{_id IN }, $ids ],
        );
    }

    SLight::Core::DB::run_delete(
        from  => $self->{'base_table'},
        where => [ 'id IN ', $ids ],
    );

    return $deleted_count;
} # }}}

# vim: fdm=marker
1;
