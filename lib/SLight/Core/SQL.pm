package SLight::Core::SQL;
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
use base 'Exporter';
our @EXPORT_OK = qw(
    sql_connect

    sql_build_query

    sql_query

    sql_select
    sql_insert
    sql_update
    sql_delete
);

our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);

use Carp::Assert::More qw( assert_defined );

use DBI;
use Params::Validate qw{ :all };
# }}}

# Connect to a database using given DBI sting, login and password.
sub sql_connect { # {{{
    my %P = validate(
        @_,
        {
            dbi  => { type=>SCALAR },
            user => { type=>SCALAR },
            pass => { type=>SCALAR },
        }
    );

    my $options = {
        AutoCommit => 1,
        PrintError => 1
    };
    my $dbh = DBI->connect("dbi:". $P{'dbi'}, $P{'user'}, $P{'pass'}, $options);

    return $dbh;
} # }}}

sub sql_query { # {{{
    my %P = validate(
        @_,
        {
            'dbh'   => { type=>OBJECT },
            'query' => { type=>ARRAYREF | SCALAR },

		    'debug' => { type=>BOOLEAN, optional=>1 },
        }
    );

    # Must prepare string for DBI to run.
    my $query = q{};
    if (ref $P{'query'} eq 'ARRAY') {
        my $i = 0;
        foreach my $part (@{ $P{'query'} }) {
            if ($i % 2 == 0) {
                # Uneven elements are copied as-is.
                $query .= $part;
            }
            else {
                # Even elements are escaped.
                $query .= sql_quote($P{'dbh'}, $part);
            }
            $i++;
        }
    }
    else {
        # Strings are not quoted, they are processed as they are.
        $query = $P{'query'};
    }

#    $P{'debug'} = 1;

    if ($P{'debug'}) {
        print STDERR "Debug DB: $query\n";
    }

    my $sth;
    assert_defined ($sth = $P{'dbh'}->prepare( $query ), "Query prepared: [ $query ]!");
	assert_defined ($sth->execute(), "Query executed: [ $query ]!");

    return $sth;
} # }}}

sub sql_quote { # {{{
    my ( $dbh, $part ) = @_;

    if (ref $part eq 'ARRAY') {
        # Tables are escaped as a coma separated list.
        my @values;
        foreach my $value (@{ $part }) {
            if (ref $value eq 'SCALAR') {
                push @values, ${ $value };
            }
            else {
                push @values, $dbh->quote($value);
            }
        }

        return q{ (}. ( join q{, }, @values ) .q{) };
    }

    if (ref $part eq 'SCALAR') {
        # Force raw data, copy 'as is'.
        return ${ $part };
    }

    # Escape this scalar
    return $dbh->quote($part);
} # }}}

sub sql_select { # {{{
    my %P = validate(
        @_,
        {
            'dbh'      => { type=>OBJECT },
            'distinct' => { type=>BOOLEAN, optional=>1 },
    		'columns'  => { type=>ARRAYREF },
		    'from'     => { type=>SCALAR },

	    	'where'    => { type=>ARRAYREF, optional=>1 },
    		'group_by' => { type=>ARRAYREF, optional=>1 },
		    'order_by' => { type=>ARRAYREF, optional=>1 },
		    'debug'    => { type=>BOOLEAN, optional=>1 },
        }
    );

    my %options = %P;
    
    $options{'type'} = 'select';
    $options{'table'} = $P{'from'};

    delete $options{'from'};

    return sql_query(
        dbh   => $P{'dbh'},
        query => sql_build_query( %options ),
        debug  => $P{'debug'},
    );
} # }}}

sub sql_insert { # {{{
    my %P = validate(
        @_,
        {
            'dbh'    => { type=>OBJECT },
		    'into'   => { type=>SCALAR },
		    'values' => { type=>HASHREF },
		    'debug'  => { type=>BOOLEAN, optional=>1 },
        }
    );

    return sql_query(
        dbh   => $P{'dbh'},
        query => sql_build_query(
            'dbh'    => $P{'dbh'},
            'type'   => 'insert',
            'table'  => $P{'into'},
            'values' => $P{'values'},
            'debug'  => $P{'debug'},
        ),
        debug => $P{'debug'},
    );
} # }}}

# Options:
#   diff : perform diff on on 'set' values, filter out the ones, that are identical to the ones provided in 'diff'
sub sql_update { # {{{
    my %P = validate(
        @_,
        {
            'dbh'   => { type=>OBJECT },
		    'table' => { type=>SCALAR },
		    'set'   => { type=>HASHREF },
	    	'where' => { type=>ARRAYREF, optional=>1 },
		    'debug' => { type=>BOOLEAN, optional=>1 },
            'diff'  => { type=>HASHREF, optional=>1 },
        }
    );

    if ($P{'diff'}) {
        my @fields = keys %{ $P{'set'} };
        foreach my $field (@fields) {
            if (defined $P{'diff'}->{$field} and $P{'diff'}->{$field} eq $P{'set'}->{$field}) {
                delete $P{'set'}->{$field};
            }
        }
    }

    if (not scalar keys %{ $P{'set'} }) {
        return;
    }

    return sql_query(
        dbh   => $P{'dbh'},
        query => sql_build_query(
            dbh    => $P{'dbh'},
            type   => 'update',
            table  => $P{'table'},
            set    => $P{'set'},
            where  => $P{'where'},
            debug  => $P{'debug'},
        ),
        debug  => $P{'debug'},
    );
} # }}}

sub sql_delete { # {{{
    my %P = validate(
        @_,
        {
            'dbh'   => { type=>OBJECT },
            'from'  => { type=>SCALAR },
	    	'where' => { type=>ARRAYREF, optional=>1 },
		    'debug' => { type=>BOOLEAN, optional=>1 },
        }
    );

    return sql_query(
        dbh   => $P{'dbh'},
        query => sql_build_query(
            dbh    => $P{'dbh'},
            type   => 'delete',
            table  => $P{'from'},
            where  => $P{'where'},
            debug  => $P{'debug'},
        ),
        debug  => $P{'debug'},
    );
} # }}}

# Construct query from given parts. Returns array that can be used with sql_query.
# Generally internal function used by some other sql_* functions.
sub sql_build_query { # {{{
    my %P = validate(
        @_,
        {
            'dbh'      => { type=>OBJECT },
		    'type'     => { type=>SCALAR },
		    'table'    => { type=>SCALAR },

		    'values'   => { type=>HASHREF, optional=>1 },
		    'set'      => { type=>HASHREF, optional=>1 },
            'distinct' => { type=>BOOLEAN, optional=>1 },
		    'columns'  => { type=>ARRAYREF, optional=>1 },
		    'where'    => { type=>ARRAYREF, optional=>1 },
		    'group_by' => { type=>ARRAYREF, optional=>1 },
		    'order_by' => { type=>ARRAYREF, optional=>1 },
		    'debug'    => { type=>BOOLEAN, optional=>1 },
        }
    );

    my %types = (
        select => {
            table => ' FROM',
        },
        insert => {
            table => ' INTO',
        },
        update => {
            table => q{},
        },
        delete => {
            table => ' FROM',
        }
    );
    assert_defined($types{ $P{'type'} }, "Type: ". $P{'type'} ." supported");

    my @query = ( uc $P{'type'} );
    
    if ($P{'distinct'}) {
        $query[-1] .= q{ DISTINCT };
    }

    if ($P{'columns'}) {
        $query[-1] .= q{ `}. ( join q{`, `}, @{ $P{'columns'} } ) .q{`};
    }

    if ($P{'table'}) {
        $query[-1] .= $types{ $P{'type'} }->{'table'} .q{ }. $P{'table'};

        if ($P{'values'}) {
            my (@fields, @values);
            foreach my $field (sort keys %{ $P{'values'} }) {
                push @fields, q{`}. $field .q{`};
                push @values, $P{'values'}->{$field};
            }

            $query[-1] .= q{ (}. (join q{, }, @fields) .q{) VALUES };

            push @query, \@values;
        }

        if ($P{'set'}) {
            my @set_array;
            my $prefix = q{`};
            foreach my $field (sort keys %{ $P{'set'} }) {
                push @set_array, $prefix . $field . q{`=}, $P{'set'}->{$field};
                
                $prefix = q{, `};
            }
            $query[-1] .= q{ SET }. shift @set_array;
            push @query, @set_array;
        }
    }

    if ($P{'where'}) {
        if (scalar @query % 2 == 0) {
            push @query, q{ WHERE }. shift @{ $P{'where'} };
        }
        else {
            $query[-1] .= q{ WHERE }. shift @{ $P{'where'} };
        }

        push @query, @{ $P{'where'} };
    }

    if ($P{'group_by'}) {
        if (scalar @query % 2 == 0) {
            push @query, q{ GROUP BY }. ( join ", ", @{ $P{'group_by'} } );
        }
        else {
            $query[-1] .= q{ GROUP BY }. ( join ", ", @{ $P{'group_by'} } );
        }
    }

    if ($P{'order_by'}) {
        if (scalar @query % 2 == 0) {
            push @query, q{ ORDER BY }. ( join ", ", @{ $P{'order_by'} } );
        }
        else {
            $query[-1] .= q{ ORDER BY }. ( join ", ", @{ $P{'order_by'} } );
        }
    }

    return \@query;
} # }}}


# vim: fdm=marker
1;
