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
            has_owner    => { type=>SCALAR, optional=>1, },
            has_assets   => { type=>SCALAR, optional=>1, },
            has_comments => { type=>SCALAR, optional=>1, },
            
            cache_namespace => { type=>SCALAR, optional=>1, },
        }
    );
    my %P = @_;

    my $self = {
        table => $P{'table'},

        columns => $P{'columns'},

        default_columns => [],

        refers_self  => ( $P{'refers_self'}  or 0 ),
        has_metadata => ( $P{'has_metadata'} or 0 ),
        has_owner    => ( $P{'has_owner'} or 0 ),
        has_assets   => ( $P{'has_assets'} or 0 ),
        has_comments => ( $P{'has_comments'} or 0 ),

        _field_def => {},
    };

    # Sane default:
    $self->{'_field_def'}->{'id'} = {
        native => 1,
    };

    foreach my $column (@{ $self->{'columns'} }) {
        $self->{'_field_def'}->{$column} = {
            native => 1,
        };

        push @{ $self->{'default_columns'} }, $column;
    }

    if ($self->{'has_metadata'}) {
        $self->{'_field_def'}->{'metadata'} = {
            native => 1,
        };

        push @{ $self->{'default_columns'} }, 'metadata';
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

    

#    use Data::Dumper; warn Dumper $self;

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

        push @{ $self->{'default_columns'} }, $namespace .q{.}. $field;
    }

    $self->{'_field_def'}->{ $spec->{'_key_field'} } = {
        native   => 1,
        internal => 1,
    };

    return;
} # }}}

sub _hook_referenced { # {{{
    my ( $self, $namespace, $spec ) = @_;

    my $callbacks = delete $spec->{'cb'};

    $spec->{'_accessor'} = SLight::Core::Accessor->new(%{ $spec });

    $spec->{'cb'} = $callbacks;

    $self->{'_field_def'}->{$namespace} = {
        referenced => 1,

        spec => $spec,
    };

    push @{ $self->{'default_columns'} }, $namespace;

    return;
} # }}}



sub add_ENTITY { # {{{
    my ( $self, %P ) = @_;

    my $_debug = delete $P{'_debug'};

    SLight::Core::DB::check();

    if ($self->{'has_metadata'} and defined $P{'metadata'}) {
        $P{'metadata'} = Dump($P{'metadata'});
    }

    if ($self->{'has_owner'}) {
        if (my $email = delete $P{'email'}) {
            $P{'Email_id'} = SLight::Core::Email::get_email_id($email, 1);
        }
    }

    # Support for 'referencing' items.
    my @fields = keys %P;
    my %referencing_items;
    foreach my $field (@fields) {
        assert_defined($self->{'_field_def'}->{$field}, 'Field configured: '. $field);

        if ($self->{'_field_def'}->{$field}->{'referenced'}) {
            my $value = delete $P{$field};

            $referencing_items{ $field } = $value;
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
        foreach my $field (keys %referencing_items) {
            my $spec = $self->{'_field_def'}->{$field}->{'spec'};

            # Note: Reference to parent table should ALREADY be in the 'key' hash.
            foreach my $item (&{ $spec->{'cb'}->{'put'} }( $entity_id, $referencing_items{$field} ) ) {
#                use Data::Dumper; warn "Item: " . Dumper $item;

                $spec->{_accessor}->add_ENTITY(
                    %{ $item->{'key'} },
                    %{ $item->{'val'} }
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
    
    my $_skip_checks = delete $P{'_skip_checks'};

    my $entity_id = delete $P{'id'};

    # Check if the entity exist at all.
    if (not $_skip_checks) {
        my $sth = SL_db_select($self->{'table'}, [qw( id )], { id => $entity_id });
        my ( $exists ) = $sth->fetchrow_array();
        if (not $exists) {
            return;
        }
    }

    SLight::Core::DB::check();

    if ($self->{'has_metadata'} and defined $P{'metadata'}) {
        $P{'metadata'} = Dump($P{'metadata'});
    }

    if ($self->{'has_owner'}) {
        if (my $email = delete $P{'email'}) {
            $P{'Email_id'} = SLight::Core::Email::get_email_id($email, 1);
        }
    }

    # Support for 'referencing' items.
    my @fields = keys %P;
    my %referencing_items;
    foreach my $field (@fields) {
        assert_defined($self->{'_field_def'}->{$field}, 'Field configured: '.$field);

#        use Data::Dumper; warn Dumper $self->{'_field_def'}->{$field};

        if ($self->{'_field_def'}->{$field}->{'referenced'}) {
            my $value = delete $P{$field};

            $referencing_items{ $field } = $value;
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
        foreach my $field (keys %referencing_items) {
            my $spec = $self->{'_field_def'}->{$field}->{'spec'};

            # This is implemented QUICK & DIRTY.
            # Updates should not be that frequent, so this should be enough.
            foreach my $item (&{ $spec->{'cb'}->{'put'} }( $entity_id, $referencing_items{$field} ) ) {
#                use Data::Dumper; warn "Does it exist? " . Dumper $item->{'key'};

                # Does this item already exist?
                # Note: Reference to parent table should ALREADY be in the 'key' hash.
                my $existing = $spec->{_accessor}->get_ENTITIES_ids_where(
                    %{ $item->{'key'} },
                );

#                use Data::Dumper; warn "Existing: " . Dumper $existing;

                if (scalar @{ $existing }) {
                    $spec->{_accessor}->update_ENTITIES(
                        ids => $existing,

                        %{ $item->{'val'} },
        
                        _debug => $_debug,
                    );
                }
                else {
                    $spec->{_accessor}->add_ENTITY(
                        %{ $item->{'key'} },
                        %{ $item->{'val'} }
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
        $self->update_ENTITY(
            %P,

            _skip_checks => 1,

            id => $id,
        );
    }

    return;
} # }}}

sub get_ENTITY { # {{{
    my ( $self, $id, $_debug ) = @_;

    assert_positive_integer($id);

    my ($sth, $select_meta) = $self->_select_ENTITIES(
        _fields => $self->{'default_columns'},

        id => [ $id ],

        _debug => $_debug,
    );

    my $entity = $sth->fetchrow_hashref();

    # Nothing found in DB? Exit ASAP...
    if (not $entity) {
        if ($_debug) { print STDERR "Nothing found!\n"; }
        return;
    }
    
    my $entities = $self->_post_process_entities( [ $entity ], $select_meta);
    
#    use Data::Dumper; warn Dumper $entities->[0];

    return $entities->[0];
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

    my $entities = $self->_post_process_entities( [ $entity ], $select_meta);
    
    return $entities->[0];
} # }}}

sub get_ENTITIES { # {{{
    my ( $self, $ids, $_debug ) = @_;

    assert_listref($ids);

    my ($sth, $select_meta) = $self->_select_ENTITIES(
        _fields => $self->{'default_columns'},

        id => $ids,
    );

    my @entities; 
    while (my $entity = $sth->fetchrow_hashref()) {
        push @entities, $entity;
    }

    return $self->_post_process_entities(\@entities, $select_meta);
} # }}}

sub get_ENTITIES_where { # {{{
    my ( $self, %P ) = @_;

    my ($sth, $select_meta) = $self->_select_ENTITIES(
        %P,
        
        _fields => $self->{'default_columns'},
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

sub count_ENTITIES_where { # {{{
    my ( $self, %P ) = @_;

    # Yes, there are faster algorythms, but there is no faster implementation ;)
    return scalar @{ $self->get_ENTITIES_ids_where(%P) };
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

            if ($P{$field} and ref $P{$field}) {
                $where{ $field } = { '-in' => $P{$field} };
            }
            else {
                $where{ $field } = $P{$field};
            }

            next;
        }

        if ($P{$field} and ref $P{$field}) {
            $where{ $self->{'table'} .q{.}. $field } = { '-in' => $P{$field} };
        }
        else {
            $where{ $self->{'table'} .q{.}. $field } = $P{$field};
        }
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
            $select_meta{'referenced'}->{ $field } = 1;

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
            my $spec = $self->{'_field_def'}->{$namespace}->{'spec'};

#            use Data::Dumper; warn Dumper $spec;

            my $entity_pool = $spec->{_accessor}->get_ENTITIES_fields_where(
                _fields => $spec->{'columns'},

                $self->{'table'} .q{_id} => [ keys %mapping ]
            );

#            use Data::Dumper; warn 'Pool: ' .  Dumper $entity_pool;

            foreach my $entity (@{ $entity_pool }) {
                push @{ $mapping{ $entity->{ $self->{'table'} .q{_id} } }->{$namespace} }, $entity;
            }

            # Now, that ALL entities are sorted out...
            foreach my $entity (@{ $entities }) {
                $entity->{$namespace} = &{ $spec->{'cb'}->{'get'} }( $entity->{$namespace} );
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

################################################################################
#                           Utility methods
################################################################################


sub timestamp_2_timedate { # {{{
    my ( $self, $timestamp ) = @_;

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime $timestamp;

    return sprintf q{%04d-%02d-%02d %02d:%02d:%02d}, $year + 1900, $mon + 1, $mday, $hour, $min, $sec;
} # }}}


################################################################################
#                           Internal routines
################################################################################


# Owner/Email handling.

sub _pack_email { # {{{
    my ( $self, $P ) = @_;
    
    # Get or assign ID of the email:
    if ($P->{'email'}) {
        $P->{'email_id'} = SLight::Core::Email::get_email_id(delete $P->{'email'}, 1);
    }

    return; # Works in place.
} # }}}

# vim: fdm=marker
1;
