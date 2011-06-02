package SLight::Core::Accessor;
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

use SLight::Core::DB qw( SL_db_select );
use SLight::Core::Email;
use SLight::Core::Cache qw( Cache_get Cache_put Cache_invalidate Cache_invalidate_referenced );

use Carp::Assert::More qw( assert_defined assert_positive_integer assert_listref );
use Params::Validate qw( :all );
use YAML::Syck;
# }}}

# Note: referenced/refers code is to be optimized, as soon it is provided to be useful.

# Purpose:
#   Create and return handler object for some entities.
sub new { # {{{
    my $class = shift;
    validate(
        @_,
        {
            table   => { type=>SCALAR, },
            columns => { type=>ARRAYREF, },

            referenced => { type=>HASHREF, optional=>1,},
            refers     => { type=>HASHREF, optional=>1, },

            refers_self  => { type=>SCALAR, optional=>1, },
            has_metadata => { type=>SCALAR, optional=>1, }, # Rows from main table contain 'metadata' column
        }
    );
    my %P = @_;

    my $self = {
        table => $P{'table'},

        columns => $P{'columns'},

        refers_self  => ( $P{'refers_self'}  or 0 ),
        has_metadata => ( $P{'has_metadata'} or 0 ),

        _field_def => {},
    };

    foreach my $column (@{ $self->{'columns'} }) {
        $self->{'_field_def'}->{$column} = {
            native => 1,
        };
    }

    if ($self->{'has_metadata'}) {
        $self->{'_field_def'}->{'metadata'} = {
            native => 1,
        };
    }

    foreach my $opt (qw( referenced refers )) {
        if ($P{$opt}) {
            $self->{$opt} = $P{$opt};
        }
    }

    bless $self, $class;

    if ($self->{'refers'}) {
        foreach my $namespace (keys %{ $self->{'refers'} }) {
            $self->_hook_refers($namespace, $self->{'refers'}->{$namespace});
        }
    }
    
    if ($self->{'referenced'}) {
        foreach my $namespace (keys %{ $self->{'referenced'} }) {
            $self->_hook_referenced($namespace, $self->{'referenced'}->{$namespace});
        }
    }

    return $self;
} # }}}

sub _hook_refers { # {{{
    my ( $self, $namespace, $spec ) = @_;

    $spec->{'namespace'} = $namespace;
    
    $spec->{'_key_field'} = $spec->{'table'} . q{_id};

    foreach my $field (@{ $spec->{'columns'} }) {
        $self->{'_field_def'}->{$namespace .q{.}. $field} = {
            refers => 1,

            spec => $spec,
        };
    }

    return;
} # }}}

sub _hook_referenced { # {{{
    my ( $self, $namespace, $spec ) = @_;

    $spec->{'namespace'} = $namespace;
    
    $spec->{'_key_field'} = $self->{'table'} . q{_id};
    
    foreach my $field (@{ $spec->{'columns'} }) {
        $self->{'_field_def'}->{$namespace .q{.}. $field} = {
            referenced => 1,

            _column => $field,

            spec => $spec,
        };
    }

    return;
} # }}}



sub add_ENTITY { # {{{
    my ( $self, %P ) = @_;

    my $_debug = delete $P{'_debug'};

    SLight::Core::DB::check();

    if ($self->{'has_metadata'} and defined $P{'metadata'}) {
        $P{'metadata'} = Dump($P{'metadata'});
    }

    # Support for 'referencing' items.
    my @fields = keys %P;
    my %referencing_items;
    foreach my $field (@fields) {
        if ($self->{'_field_def'}->{$field}->{'referenced'}) {
            my $value = delete $P{$field};

            $referencing_items{ $self->{'_field_def'}->{$field}->{'spec'}->{'namespace'} }->{ $self->{'_field_def'}->{$field}->{'_column'} } = $value;
        }
    }

#    use Data::Dumper; warn Dumper \%P;

    SLight::Core::DB::run_insert(
        'into'   => $self->{'table'},
        'values' => \%P,
        'debug'  => $_debug,
    );

    my $entity_id = SLight::Core::DB::last_insert_id();

#    use Data::Dumper; warn Dumper \%referencing_items;

    if (scalar %referencing_items) {
        foreach my $namespace (keys %referencing_items) {
            my %rows;

            foreach my $column (keys %{ $referencing_items{$namespace} }) {
                foreach my $key (keys %{ $referencing_items{$namespace}->{$column} }) {
                    $rows{$key}->{$column} = $referencing_items{$namespace}->{$column}->{$key};
                }
            }

            foreach my $row_key (keys %rows) {
                my $row = $rows{$row_key};

                $row->{ $self->{'referenced'}->{$namespace}->{'key'} } = $row_key;

                $row->{ $self->{'referenced'}->{$namespace}->{'_key_field'} } = $entity_id;

#                use Data::Dumper; warn Dumper $row;

                SLight::Core::DB::run_insert(
                    'into'   => $self->{'referenced'}->{$namespace}->{'table'},
                    'values' => $row,
                    'debug'  => $_debug,
                );
            }
        }
    }

    return $entity_id;
} # }}}

sub update_ENTITY { # {{{
    my ( $self, %P ) = @_;

#    use Data::Dumper; warn 'IN ' . Dumper \%P;

    my $_debug = delete $P{'_debug'};

    my $entity_id = delete $P{'id'};

    SLight::Core::DB::check();

    if ($self->{'has_metadata'} and defined $P{'metadata'}) {
        $P{'metadata'} = Dump($P{'metadata'});
    }

    # Support for 'referencing' items.
    my @fields = keys %P;
    my %referencing_items;
    foreach my $field (@fields) {
        assert_defined($self->{'_field_def'}->{$field});

#        use Data::Dumper; warn Dumper $self->{'_field_def'}->{$field};

        if ($self->{'_field_def'}->{$field}->{'referenced'}) {
            my $value = delete $P{$field};

            $referencing_items{ $self->{'_field_def'}->{$field}->{'spec'}->{'namespace'} }->{ $self->{'_field_def'}->{$field}->{'_column'} } = $value;
        }
    }

    SLight::Core::DB::run_update(
        'table'  => $self->{'table'},
        'set'    => \%P,
        'debug'  => $_debug,
        'where'  => [
            q{id = }, $entity_id,
        ],
    );

#    use Data::Dumper; warn Dumper \%referencing_items;

    if (scalar %referencing_items) {
        foreach my $namespace (keys %referencing_items) {
            my %rows;

            foreach my $column (keys %{ $referencing_items{$namespace} }) {
                foreach my $key (keys %{ $referencing_items{$namespace}->{$column} }) {
                    $rows{$key}->{$column} = $referencing_items{$namespace}->{$column}->{$key};
                }
            }
            my $sth = SL_db_select(
                $self->{'referenced'}->{$namespace}->{'table'},
                [ $self->{'referenced'}->{$namespace}->{'key'} ],
                {
                    $self->{'referenced'}->{$namespace}->{'key'}        => { -in => [ keys %rows ] },
                    $self->{'referenced'}->{$namespace}->{'_key_field'} => $entity_id,
                }
            );
            my %keys_exist;
            while (my ($key) = $sth->fetchrow_array()) {
                $keys_exist{$key} = 1;
            }

            foreach my $row_key (keys %rows) {
                my $row = $rows{$row_key};

                if ($keys_exist{$row_key}) {
#                    use Data::Dumper; warn "Update referenced " . Dumper $row;

                    SLight::Core::DB::run_update(
                        'table'  => $self->{'referenced'}->{$namespace}->{'table'},
                        'set'    => $row,
                        'debug'  => $_debug,
                        'where'  => [
                            $self->{'referenced'}->{$namespace}->{'key'} . q{ = }, $row_key,

                            q{ AND } . $self->{'referenced'}->{$namespace}->{'_key_field'} .q{ = }, $entity_id,
                        ],
                    );
                }
                else {
                    SLight::Core::DB::run_insert(
                        'into'   => $self->{'referenced'}->{$namespace}->{'table'},
                        'values' => {
                            %{ $row },
                            
                            $self->{'referenced'}->{$namespace}->{'key'} => $row_key,

                            $self->{'referenced'}->{$namespace}->{'_key_field'} => $entity_id,
                        },
                        'debug'  => $_debug,
                    );
                }
            }
        }
    }

    return $entity_id;
} # }}}

# For now a quick hack. If will be used, it will be rewritten to increase performance.
sub update_ENTITIES { # {{{
    my ( $self, %P ) = @_;

    my $ids = delete $P{'ids'};

    foreach my $id (@{ $ids }) {
        $self->update_ENTITY(%P, id=>$id);
    }

    return;
} # }}}

sub get_ENTITY { # {{{
    my ( $self, $id, $_debug ) = @_;

    assert_positive_integer($id);

    my ($sth, $select_meta) = $self->_select_ENTITIES(
        _fields => [ keys %{ $self->{'_field_def'} } ],

        id => [ $id ],
    );

    my $entity = $sth->fetchrow_hashref();

    # Nothing found in DB? Exis ASAP...
    if (not $entity) {
        return;
    }
    
#    use Data::Dumper; warn Dumper $entity;

    return @{ $self->_post_process_entities( [ $entity ], $select_meta) }->[0];
} # }}}

sub get_ENTITY_fields { # {{{
    my ( $self, $id, $fields, $_debug ) = @_;

    assert_positive_integer($id);
    assert_listref($fields);

    my ($sth, $select_meta) = $self->_select_ENTITIES(
        _fields => $fields,

        id => [ $id ],
    );

    my $entity = $sth->fetchrow_hashref();

    # Nothing found in DB? Exis ASAP...
    if (not $entity) {
        return;
    }
    
#    use Data::Dumper; warn Dumper $entity;

    return @{ $self->_post_process_entities( [ $entity ], $select_meta) }->[0];
} # }}}

sub get_ENTITIES { # {{{
    my ( $self, $ids, $_debug ) = @_;

    assert_listref($ids);

    my ($sth, $select_meta) = $self->_select_ENTITIES(
        _fields => [ keys %{ $self->{'_field_def'} } ],

        id => $ids,
    );

    my @entities; 
    while (my $entity = $sth->fetchrow_hashref()) {
        push @entities, $entity;
    }

    return $self->_post_process_entities(\@entities, $select_meta);
} # }}}

sub get_ENTITIES_fields { # {{{
    my ( $self, $ids, $fields, $_debug ) = @_;

    assert_listref($ids);
    assert_listref($fields);

    my ($sth, $select_meta) = $self->_select_ENTITIES(
        _fields => $fields,

        id => $ids,
    );

    my @entities; 
    while (my $entity = $sth->fetchrow_hashref()) {
        push @entities, $entity;
    }

    return $self->_post_process_entities(\@entities, $select_meta);
} # }}}

sub get_ENTITIES_fields_where { # {{{
    my ( $self, %P ) = @_;

    assert_listref($P{'_fields'});

    my ($sth, $select_meta) = $self->_select_ENTITIES(%P);

    my @entities;
    while (my $entity = $sth->fetchrow_hashref()) {
        push @entities, $entity;
    }

    return $self->_post_process_entities(\@entities, $select_meta);
} # }}}

sub get_ENTITIES_ids_where { # {{{
    my ( $self, %P ) = @_;

    my ($sth, $select_meta) = $self->_select_ENTITIES(
        _fields => [ 'id' ],

        %P,
    );

    my @ids;
    while (my ( $id ) = $sth->fetchrow_array()) {
        push @ids, $id;
    }

#    use Data::Dumper; warn Dumper \@ids;

    return \@ids;
} # }}}

sub _select_ENTITIES { # {{{
    my ( $self, %P ) = @_;

    SLight::Core::DB::check();

    my $fields = delete $P{'_fields'};
    
    my $_debug = delete $P{'_debug'};

    my @columns = ( $self->{'table'} . q{.`id`} );

    my %select_meta;
    my %tables = (
        $self->{'table'} => 1
    );
    my %where;
    my %referenced;
    foreach my $field (keys %P) {
        assert_defined($self->{'_field_def'}->{$field}, $field);

        if ($self->{'_field_def'}->{$field}->{'refers'}) {
            my $spec = $self->{'_field_def'}->{$field}->{'spec'};

            $tables{ $spec->{'table'} . q{ AS }. $spec->{'namespace'} } = 1;
            
            $where{ $spec->{'namespace'} . q{.id = } } = \$spec->{'_key_field'};

            $where{ $field } = { '-in' => $P{$field} };

            next;
        }

        $where{ $self->{'table'} .q{.}. $field } = { '-in' => $P{$field} };
    }

    foreach my $field (@{ $fields }) {
        if ($self->{'_field_def'}->{$field}->{'native'}) {
            push @columns, $self->{'table'} .q{.}. $field;

            next;
        }

        if ($self->{'_field_def'}->{$field}->{'refers'}) {
            my $spec = $self->{'_field_def'}->{$field}->{'spec'};

            $tables{ $spec->{'table'} . q{ AS }. $spec->{'namespace'} } = 1;
            
            $where{ $spec->{'namespace'} . q{.id = } } = \$spec->{'_key_field'};

            push @columns, $field . q{ AS `}. $field .q{`};

            next;
        }

        if ($self->{'_field_def'}->{$field}->{'referenced'}) {
            # Will be done on second stage.
            my $spec = $self->{'_field_def'}->{$field}->{'spec'};

            $select_meta{'referenced'}->{ $spec->{'namespace'} }->{'spec'} = $spec;

            push @{ $select_meta{'referenced'}->{ $spec->{'namespace'} }->{'fields'} }, $field;
            
            push @{ $select_meta{'referenced'}->{ $spec->{'namespace'} }->{'columns'} }, (sprintf q{`%s`.`%s` AS `%s`}, $spec->{'table'}, $self->{'_field_def'}->{$field}->{'_column'}, $field);

            next;
        }
    }

#    use Data::Dumper; warn Dumper {
#        tab => [ keys %tables ],
#        col => \@columns,
#        whe => \%where
#    };

    my $sth = SL_db_select([ keys %tables ], \@columns, \%where);

#    use Data::Dumper; warn Dumper \%select_meta;

    return ( $sth, \%select_meta );
} # }}}

sub _post_process_entities { # {{{
    my ( $self, $entities, $select_meta ) = @_;

#    use Data::Dumper; warn Dumper $select_meta;

    my %mapping;
    foreach my $entity (@{ $entities }) {
        # Metadata processing.
        if ($self->{'has_metadata'} and defined $entity->{'metadata'}) {
            $entity->{'metadata'} = Load($entity->{'metadata'});
        }

        if ($select_meta->{'referenced'}) {
            $mapping{ $entity->{'id'} } = $entity;
        }

        # Other stuff may follow.
    }

    if ($select_meta->{'referenced'}) {
#        use Data::Dumper; warn Dumper $select_meta->{'referenced'};

        foreach my $namespace (keys %{ $select_meta->{'referenced'} }) {
            my $spec = $select_meta->{'referenced'}->{$namespace}->{'spec'};

#            use Data::Dumper; warn Dumper $spec;

            my %where = (
                $self->{'table'} .q{_id} => { '-in' => [ keys %mapping ] },
            );

            my $sth = SL_db_select($spec->{'table'}, [ $self->{'table'} .q{_id}, $spec->{'key'}, @{ $select_meta->{'referenced'}->{ $namespace }->{'columns'} } ], \%where);

            while (my $referenced = $sth->fetchrow_hashref()) {
#                use Data::Dumper; warn Dumper $referenced;

                foreach my $column (@{ $select_meta->{'referenced'}->{ $namespace }->{'fields'} }) {
                    my $key_value = $referenced->{ $spec->{'key'} };

                    $mapping{ $referenced->{ $self->{'table'} .q{_id} } }->{ $column }->{ $key_value } = $referenced->{$column};
                }
            }
        }
    }

#    use Data::Dumper; warn Dumper $entities;

    return $entities;
} # }}}

sub delete_ENTITY { # {{{
    my ( $self, $id ) = @_;

    return $self->delete_ENTITYs( [$id] );
} # }}}

sub delete_ENTITYs { # {{{
    my ( $self, $ids, $_debug ) = @_;

    SLight::Core::DB::run_delete(
        from  => $self->{'table'},
        where => [ 'id IN ', $ids ],
        debug => $_debug,
    );

    return;
} # }}}


# vim: fdm=marker
1;
