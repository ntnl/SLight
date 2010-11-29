package SLight::Core::SQLite;
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

use SLight::Core::SQL qw{
    sql_connect

    sql_query

    sql_select
    sql_insert
    sql_update
    sql_delete
};

use Params::Validate qw{ :all };
# }}}

# Create SQLite wraper object.
sub new { # {{{
    my $class = shift;
    my %P = validate(
        @_,
        {
            db => { type=>SCALAR },
        }
    );

    my $self = {
        dbh =>  sql_connect(
            dbi  => 'SQLite:dbname='. $P{'db'},
            user => q{},
            pass => q{},
        ),
        db_file => $P{'db'},
    };

    # Enable support for UTF-8
    $self->{'dbh'}->{'sqlite_unicode'} = 1;

    $self->{'dbh'}->do("PRAGMA foreign_keys = ON");

    # Note to self:
    #   it used to be 'unicode' instead of 'sqlite_unicode'

    bless $self, $class;

    return $self;
} # }}}

sub disconnect { # {{{
    my ( $self ) = @_;

    return $self->{'dbh'}->disconnect();
} # }}}

sub run_query { # {{{
    my $self = shift;

    return sql_query(
        dbh => $self->{'dbh'},
        @_
    );
} # }}}

sub run_insert { # {{{
    my $self = shift;

    return sql_insert(
        dbh => $self->{'dbh'},
        @_
    );
} # }}}

sub run_update { # {{{
    my $self = shift;

    return sql_update(
        dbh => $self->{'dbh'},
        @_
    );
} # }}}

sub run_delete { # {{{
    my $self = shift;

    return sql_delete(
        dbh => $self->{'dbh'},
        @_
    );
} # }}}

sub run_select { # {{{
    my $self = shift;

    return sql_select(
        dbh => $self->{'dbh'},
        @_
    );
} # }}}

# Return ID of the last inserted row (if it used AUTOINCREMENT)
# ToDo:
#   - add to tests.
sub last_insert_id { # {{{
    my $self = shift;

    my $sth = $self->run_query(
        query => "SELECT last_insert_rowid()"
    );

    return $sth->fetchrow_array();
} # }}}

# Methods used for inter-operatibility.

# Return path to check-file.
# This file will be monitored by other sub-systems.
sub touch_file_path { # {{{
    my ( $self ) = @_;

    return $self->{'db_file'};
} # }}}

# Should return true if database can be accessed in read-only mode.
sub read_only { # {{{
    my ( $self ) = @_;

    if (-w $self->{'db_file'}) {
        return;
    }

    return 1;
} # }}}

# Return reference to a string, that will be used as NOW()-like function.
#
# If You must, in tests, set time to some fixed value, use the 'TEST_TIMESTAMP_FUNC' env var.
# It will overwrite the default routine, with any SQL code. This should be done ONLY in tests.
# This will not be quotted, so make sure it's SQL-safe!
sub NOW { # {{{
    my $function_string = ( $ENV{'TEST_TIMESTAMP_FUNC'} or "CURRENT_TIMESTAMP" );

    return \$function_string;
} # }}}

# vim: fdm=marker
1;
