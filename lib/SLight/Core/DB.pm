package SLight::Core::DB;
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

use Params::Validate qw{ :all };
# }}}

my $handler = undef;

my $touch_file_path;

sub check { # {{{
    if (not $handler) {
        # Hardcoded for now.
        # In future, it will allow to connect to PostgreSQL or MySQL.
        
        require SLight::Core::SQLite;

        $handler = SLight::Core::SQLite->new(
            db => SLight::Core::Config::get_option('data_root') .q{/db/slight.sqlite}
        );

        $touch_file_path = $handler->touch_file_path();

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
