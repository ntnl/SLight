package SLight::Core::Entity;
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

use SLight::Core::DB;
use SLight::Core::Email;
use SLight::Core::Cache qw( Cache_get Cache_put Cache_invalidate Cache_invalidate_referenced );

use Carp::Assert::More qw( assert_positive_integer );
use Params::Validate qw( :all );
use YAML::Syck;
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
        
        child_has_language => $P{'child_has_language'},
            # If defined, means that '_data' items are based on key AND 'language' column.
            # In this case, '_data_lang' is mandatory.

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

    if (not ref $self->{'child_key'}) {
        $self->{'child_key'} = [ $self->{'child_key'} ];
    }

    $self->{'_really_all_fields'} = [ 'id', @{ $self->{'_all_fields'} } ];

    if ($P{'has_owner'}) {
        push @{ $self->{'_really_all_fields'} }, q{Email_id};
    }

    bless $self, $class;

    return $self;
} # }}}

# Notes to self :)
#
#
# Comment
# {
#   base_table => 'Comment_Entity',
#
#   data_fields => [qw( added status title text )],
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

    if ($self->{'has_metadata'} and defined $P{'metadata'}) {
        $P{'metadata'} = Dump($P{'metadata'});
    }
    
    if ($self->{'has_owner'}) {
        $self->_pack_email( \%P );
    }

    SLight::Core::DB::run_insert(
        'into'   => $self->{'base_table'},
        'values' => \%P,
        'debug'  => $P{'_debug'},
    );

    my $entity_id = SLight::Core::DB::last_insert_id();

    if ($data_hash) {
        my @data_values = $self->_data_values($data_hash);

        foreach my $data_entry (@data_values) {
            my $data = $data_entry->{'data'};
            if (not ref $data) {
                $data = { value=>$data };
            }

            SLight::Core::DB::run_insert(
                'into'   => $self->{'child_table'},
                'values' => {
                    %{ $data_entry->{'keys'} },
                    %{ $data },
                    $self->{'base_table'} . q{_id} => $entity_id,
                },
                'debug'  => $P{'_debug'},
            );
        }
    }

    return $entity_id;
} # }}}

sub update_ENTITY { # {{{
    my ( $self, %P ) = @_;

    assert_positive_integer($P{'id'});

#    $P{'_debug'} = 1;

    my %values;
    foreach my $field (@{ $self->{'_all_fields'} }) {
        if (exists $P{$field}) {
            $values{$field} = $P{$field};
        }
    }

    SLight::Core::DB::check();

    my $data_hash = delete $P{'_data'};

    if ($self->{'has_metadata'} and defined $values{'metadata'}) {
        $values{'metadata'} = Dump($values{'metadata'});
    }

    if ($self->{'has_owner'} and $P{'email'}) {
        $self->_pack_email( \%P );

        $values{'Email_id'} = $P{'email_id'};
    }

    SLight::Core::DB::run_update(
        'table' => $self->{'base_table'},
        'set'   => \%values,
        'where' => [
            'id = ', $P{'id'},
        ],
        'debug' => $P{'_debug'}, 
    );

    my $current_data = $self->get_ENTITY($P{'id'});
#    use Data::Dumper; warn 'current_entity: '. Dumper $current_data;

    if ($data_hash and $current_data) {
        my %current_data_values = map { $_->{'key_string'} => $_ } $self->_data_values( ($current_data->{'_data'} or {}) );
#        use Data::Dumper; warn 'current_data: '. Dumper \%current_data_values;

        my @inserts;

        my @data_values = $self->_data_values($data_hash);
        foreach my $data_entry (@data_values) {
            # Check if that entry is already in DB (We will update it in this case)
            if ($current_data_values{ $data_entry->{'key_string'} }) {
                # Update the data value.
                my @where = ( $self->{'base_table'} . q{_id = }, $P{'id'} );
                foreach my $key_column (keys %{ $data_entry->{'keys'} }) {
                    push @where, ' AND '. $key_column .' = ', $data_entry->{'keys'}->{$key_column};
                }

                if (defined $data_entry->{'data'}) {
                    SLight::Core::DB::run_update(
                        'table' => $self->{'child_table'},
                        'set'   => $data_entry->{'data'},
                        'where' => \@where,
                        'debug' => $P{'_debug'},
                    );
                }
                else {
                    SLight::Core::DB::run_delete(
                        'from'  => $self->{'child_table'},
                        'where' => \@where,
                        'debug' => $P{'_debug'},
                    );
                }
            }
            else {
                # Add this data value (is a new one)
                my %insert_values = (
                    %{ $data_entry->{'data'} },

                    $self->{'base_table'} . q{_id} => $P{'id'},
                );

                foreach my $key_column (keys %{ $data_entry->{'keys'} }) {
                    $insert_values{ $key_column } = $data_entry->{'keys'}->{$key_column};
                }

                push @inserts, {
                    'into'   => $self->{'child_table'},
                    'values' => \%insert_values,
                    'debug'  => $P{'_debug'},
                };
            }
        }

        if (scalar keys @inserts) {
            foreach my $insert (@inserts) {
                SLight::Core::DB::run_insert(%{ $insert });
            }
        }
#        die();
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
    
    if ($self->{'has_metadata'} and defined $values{'metadata'}) {
        $values{'metadata'} = Dump($values{'metadata'});
    }

    SLight::Core::DB::check();

    SLight::Core::DB::run_update(
        'table' => $self->{'base_table'},
        'set'   => \%values,
        'where' => [
            'id IN ', $P{'ids'},
        ],
        'debug' => $P{'_debug'},
    );

    return;
} # }}}

sub get_ENTITY { # {{{
    my ( $self, $id, $_debug ) = @_;

    assert_positive_integer($id);

    SLight::Core::DB::check();

    my $sth = SLight::Core::DB::run_select(
        columns => $self->{'_really_all_fields'},
        from    => $self->{'base_table'},
        where   => [ 'id = ', $id ],
        debug   => $_debug,
    );
    
    my $entity = $sth->fetchrow_hashref();

    # Nothing found in DB? Exis ASAP...
    if (not $entity) {
        return;
    }

    if ($self->{'child_table'}) {
        $self->_add_data_to_entities( { $id => $entity } );
    }

    if ($self->{'has_owner'}) {
        $self->_unpack_emails( [ $entity ] );
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

#    use Data::Dumper; warn Dumper $entity;

    return $entity;
} # }}}

sub get_all_ENTITYs { # {{{
    my ( $self, $_debug ) = @_;

    SLight::Core::DB::check();

    my $sth = SLight::Core::DB::run_select(
        columns => $self->{'_really_all_fields'},
        from    => $self->{'base_table'},
        debug   => $_debug,
    );

    my %entities = $self->_slurp_entities($sth);

    if (not scalar keys %entities) {
        return [];
    }

    if ($self->{'child_table'}) {
        $self->_add_data_to_entities(\%entities);
    }

#    use Data::Dumper; warn Dumper \%entities;

    return [ values %entities ];
} # }}}

sub get_ENTITYs { # {{{
    my ( $self, $ids, $_debug ) = @_;

    SLight::Core::DB::check();

    my $sth = SLight::Core::DB::run_select(
        columns => $self->{'_really_all_fields'},
        from    => $self->{'base_table'},
        where   => [ 'id IN ', $ids ],
        debug   => $_debug,
    );

    my %entities = $self->_slurp_entities($sth);

    if (not scalar keys %entities) {
        return [];
    }

    if ($self->{'child_table'}) {
        $self->_add_data_to_entities(\%entities);
    }
    
    if ($self->{'has_owner'}) {
        $self->_unpack_emails( [ values %entities ] );
    }


#    use Data::Dumper; warn Dumper \%entities;

    return [ values %entities ];
} # }}}

sub count_ENTITYs_where { # {{{
    my ( $self, %P ) = @_;
    
    # YES, this IS stupid, but should work... will refactor later.

    my $where = $self->_make_where(%P);

    my $sth = SLight::Core::DB::run_select(
        columns => [ 'id' ],
        from    => $self->{'base_table'},
        where   => $where,
        debug   => $P{'_debug'},
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
        debug   => $P{'_debug'},
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
        debug   => $P{'_debug'},
    );

    my %entities = $self->_slurp_entities($sth);

    if (not scalar keys %entities) {
        return [];
    }

    if ($self->{'child_table'}) {
        $self->_add_data_to_entities(\%entities);
    }

    if ($self->{'has_owner'}) {
        $self->_unpack_emails( [ values %entities ] );
    }

#    use Data::Dumper; warn Dumper \%entities;

    return [ values %entities ];
} # }}}

# Note:
#   Function uses 'id' column internally, thus this column is returned, even if not asked for.
sub get_ENTITYs_fields_where { # {{{
    my ( $self, %P ) = @_;

    SLight::Core::DB::check();

    my $where = $self->_make_where(%P);

    my %fields = map { $_ => 1 } @{ $P{'_fields'} or [] };
    $fields{'id'} = 1;

    my $sth = SLight::Core::DB::run_select(
        columns => [ keys %fields ],
        from    => $self->{'base_table'},
        where   => $where,
        debug   => $P{'_debug'},
    );

    my %entities = $self->_slurp_entities($sth);

    if (not scalar keys %entities) {
        return [];
    }

    if ($self->{'child_table'}) {
        $self->_add_data_to_entities(\%entities, $P{'_data_fields'});
    }

    if ($self->{'has_owner'}) {
        $self->_unpack_emails( [ values %entities ] );
    }

#    use Data::Dumper; warn Dumper \%entities;

    return [ values %entities ];
} # }}}

sub _slurp_entities { # {{{
    my ( $self, $sth) = @_;

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

    return %entities;
} # }}}

# Purpose:
#   Process _data hashes, before then can be used to insert or update data.
#   Turn things like:
#   {
#       q{*} => {
#           foo => { start => 1, end => 2 },
#           bar => { start => 3, end => 5 },
#       }
#   }
#   ...into:
#   [
#       { keys => { id1 => q{*}, id2 => 'foo', }, data => { start => 1, end => 2 } },
#       { keys => { id1 => q{*}, id2 => 'bar', }, data => { start => 3, end => 5 } },
#   ]
#
#   For above example, there will be the following calls:
#   ->_data_values(
#       {
#           q{*} => {
#               foo => { start => 1, end => 2 },
#               bar => { start => 3, end => 5 },
#           }
#       }
#   );
#   ->_data_values(
#       {
#           foo => { start => 1, end => 2 },
#           bar => { start => 3, end => 5 },
#       },
#       id1,
#       q{*},
#   )
sub _data_values { # {{{
    my ( $self, $data_hash, %_keys ) = @_;

    # When called by *_ENTRY* functions, _keys is not defined.
    if (not %_keys) {
        %_keys  = ();
    }
    
#    use Data::Dumper; warn "Input: " . Dumper [ $data_hash, \%_keys ];

    my @values;
    my $k_index = scalar keys %_keys;

#    use Data::Dumper; warn "Selector: " . Dumper { k_index => $k_index, k_ => $self->{'child_key'}->[ $k_index ] };

    if (1 + $k_index == scalar @{ $self->{'child_key'} }) {
        # Fetch data values.
        foreach my $key_value (keys %{ $data_hash }) {
            if (defined $data_hash->{ $key_value } and not ref $data_hash->{ $key_value }) {
                $data_hash->{ $key_value } = { value => $data_hash->{ $key_value } };
            }

            my $entry = {
                keys => {
                    %_keys,

                    $self->{'child_key'}->[$k_index] => $key_value
                },
                data => $data_hash->{ $key_value },
            };

            my @key_values;
            foreach my $kk (sort keys %{ $entry->{'keys'} }) {
                push @key_values, $entry->{'keys'}->{$kk};
            }
            $entry->{'key_string'} = join "\0", @key_values;

            push @values, $entry;
        }
    }
    else {
#        warn "Digging...\n";

        # Dig deeper... (into hash)
        foreach my $key_value (keys %{ $data_hash }) {
#            warn 'Key ('. $self->{'child_key'}->[ $k_index ] .') value: '. $key_value;

            $_keys{ $self->{'child_key'}->[ $k_index ] } = $key_value;

            push @values, $self->_data_values($data_hash->{$key_value}, %_keys);
        }
    }

    return @values;
} # }}}

sub _make_where { # {{{
    my ( $self, %P ) = @_;

    my @where;
    my $glue = q{};
    foreach my $field ('id', @{ $self->{'_all_fields'} }) {
        if (exists $P{$field}) {
            if (ref $P{$field} eq 'ARRAY') {
                push @where, $glue . $field . q{ IN }, $P{$field};
            }
            else {
                push @where, $glue . $field . q{ = }, $P{$field};
            }

            $glue = ' AND ';
        }
    }

    if (not scalar @where) {
        @where = ( q{'1' = }, 1 );
    }

    return \@where;
} # }}}

sub _add_data_to_entities { # {{{
    my ( $self, $entities, $fields, $_debug ) = @_;

    my $sth = SLight::Core::DB::run_select(
        columns => [
            @{ $fields or $self->{'child_data_fields'} },

            $self->{'base_table'} . q{_id},

            @{ $self->{'child_key'} },
        ],
        from    => $self->{'child_table'},
        where   => [
            $self->{'base_table'} . q{_id IN }, [ keys %{ $entities } ]
        ],
        debug => $_debug,
    );

    while (my $row = $sth->fetchrow_hashref()) {
        my $e_id = delete $row->{ $self->{'base_table'} . q{_id} };

        if (not $entities->{$e_id}->{'_data'}) {
            $entities->{$e_id}->{'_data'} = {};
        }

        $self->_attach_data_row($entities->{$e_id}->{'_data'}, $row);
    }

    return;
} # }}}

# Purpose:
#   Attach single '_data' item to it's hash.
#
#   This is a generic method, it can be overloaded if needed (eg. to improve performance!).
sub _attach_data_row { # {{{
    my ($self, $_data_hash, $_data_row) = @_;

#    use Data::Dumper; warn "_attach_data_row:\n" . Dumper $_data_hash, $_data_row;

    # Descend into _data_hash
    my $last_data_hash;
    my $last_column;
    foreach my $key (@{ $self->{'child_key'} }) {
        my $column = delete $_data_row->{$key};
        if (not $_data_hash->{ $column }) {
            $_data_hash->{ $column } = {};
        }

        $last_data_hash = $_data_hash;
        $last_column    = $column;

        $_data_hash = $_data_hash->{ $column };
    }

    if (scalar @{ $self->{'child_data_fields'} } == 1) {
        $last_data_hash->{$last_column} = $_data_row->{ $self->{'child_data_fields'}->[0] };
    }
    else {
        foreach my $column (keys %{ $_data_row }) {
            $_data_hash->{$column} = $_data_row->{$column};
        }
    }

#    use Data::Dumper; warn "_data_hash:\n" . Dumper $_data_hash;

    return $_data_hash;
} # }}}

sub delete_ENTITY { # {{{
    my ( $self, $id ) = @_;

    # To refactor this, or not to refactor - this is the question?
    
    return $self->delete_ENTITYs( [$id] );
} # }}}

sub delete_ENTITYs { # {{{
    my ( $self, $ids, $_debug ) = @_;

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
    
    # Before deleting main rows, their corresponding child rows must be deleted.
    if ($self->{'child_table'}) {
        SLight::Core::DB::run_delete(
            from  => $self->{'child_table'},
            where => [ $self->{'base_table'} . q{_id IN }, $ids ],
        );
    }

    SLight::Core::DB::run_delete(
        from  => $self->{'base_table'},
        where => [ 'id IN ', $ids ],
        debug => $_debug,
    );

    return $deleted_count;
} # }}}

# Owner/Email handling.

sub _pack_email { # {{{
    my ( $self, $P ) = @_;
    
    # Get or assign ID of the email:
    if ($P->{'email'}) {
        $P->{'email_id'} = SLight::Core::Email::get_email_id(delete $P->{'email'}, 1);
    }

    return; # Works in place.
} # }}}

sub _unpack_emails { # {{{
    my ( $self, $entities ) = @_;

    # Note for later:
    #   Start with slow, but working.
    #   When it works, refactor into something faster.
    foreach my $entity (@{ $entities }) {
        if ($entity->{'Email_id'}) {
            my $login;

            ( $entity->{'email'}, $login ) = SLight::Core::Email::get_by_id(delete $entity->{'Email_id'});
        }
    }

    return; # Works in place.
} # }}}

# vim: fdm=marker
1;
