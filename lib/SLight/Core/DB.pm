package SLight::Core::DB;
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
use base 'Exporter';

use SLight::Core::Config;

use SQL::Abstract;
use Params::Validate qw{ :all };
# }}}

our @EXPORT_OK = qw(
    SL_db_select
);
our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

my $handler = undef;

my $__dbh;
my $__abstract;

sub check { # {{{
    if (not $handler) {
        # Hardcoded for now.
        # In future, it will allow to connect to PostgreSQL or MySQL.
        
        require SLight::Core::SQLite;

        $handler = SLight::Core::SQLite->new(
            db => SLight::Core::Config::get_option('data_root') .q{/db/slight.sqlite}
        );

        $__dbh = $handler->get_dbh();

        # We're slowly switching to this,
        # instead of in-house solution.
        if (not $__abstract) {
            $__abstract = SQL::Abstract->new();
        }

#        print STDERR "DB Initialized.\n";
#        print STDERR "Touchfile: $touch_file_path\n";

        return $handler;
    }

    return;
} # }}}

sub disconnect { # {{{
    if ($handler) {
        $handler->disconnect();

        $handler = undef;
    }

    return;
} # }}}

# Parameters:
#   $table, \@fields, \%where, \@order
sub SL_db_select { # {{{
    my($stmt, @bind) = $__abstract->select(@_);

#    use Data::Dumper; warn Dumper \@_;
#    warn $stmt;

    my $sth = $__dbh->prepare($stmt);

    if ($sth->execute(@bind)) {
        return $sth;
    }

    return;
} # }}}

sub run_query { # {{{
    return $handler->run_query(@_);
} # }}}

sub run_insert { # {{{
    return $handler->run_insert(@_);
} # }}}

sub run_update { # {{{
    return $handler->run_update(@_);
} # }}}

sub run_delete { # {{{
    return $handler->run_delete(@_);
} # }}}

sub run_select { # {{{
    return $handler->run_select(@_);
} # }}}

sub last_insert_id { # {{{
    return $handler->last_insert_id();
} # }}}

sub read_only { # {{{
    return $handler->read_only();
} # }}}

# Return reference to a string, that will be used as NOW()-like function.
sub NOW { # {{{
    return $handler->NOW();
} # }}}

# vim: fdm=marker
1;
