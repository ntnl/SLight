package SLight::API::Permissions;
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
use base 'Exporter';

use SLight::Core::Config;
use SLight::Core::DB;

use Carp::Assert::More qw( assert_defined assert_positive_integer );
use Params::Validate qw( :all );
# }}}

our @EXPORT_OK = qw(
    set_User_access
    set_System_access
    clear_User_access
    clear_System_access

    get_User_access
    get_System_access

    can_User_access
);
our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

sub get_User_access { # {{{
    my %P = validate(
        @_,
        {
            id => { type=>SCALAR },

            handler_family => { type=>SCALAR },
            handler_class  => { type=>SCALAR, optional=>1, default=>q{*} },
            handler_action => { type=>SCALAR, optional=>1, default=>q{*} },

            handler_object => { type=>SCALAR, optional=>1, default=>q{*} },

            _debug => { type=>SCALAR, optional=>1 },
        }
    );

    my @where = ( q{User_id = }, $P{'id'} );
    foreach my $field (qw( handler_family handler_class handler_action handler_object )) {
        push @where, q{ AND } . $field . q{ = }, $P{$field},
    }

    my $sth = SLight::Core::DB::run_select(
        from    => q{User_Access},
        columns => [qw( policy )],
        where   => \@where,
        debug   => $P{'_debug'},
    );
    my ( $policy ) = $sth->fetchrow_array();

    return $policy;
} # }}}

sub get_System_access { # {{{
    my %P = validate(
        @_,
        {
            type => { type=>SCALAR },

            handler_family => { type=>SCALAR },
            handler_class  => { type=>SCALAR, optional=>1, default=>q{*} },
            handler_action => { type=>SCALAR, optional=>1, default=>q{*} },

            _debug => { type=>SCALAR, optional=>1 },
        }
    );

    my @where = ( q{user_type = }, $P{'type'} );
    foreach my $field (qw( handler_family handler_class handler_action )) {
        push @where, q{ AND } . $field . q{ = }, $P{$field},
    }

    my $sth = SLight::Core::DB::run_select(
        from    => q{System_Access},
        columns => [qw( policy )],
        where   => \@where,
        debug   => $P{'_debug'},
    );
    my ( $policy ) = $sth->fetchrow_array();

    return $policy;
} # }}}


sub set_User_access { # {{{
    my %P = validate(
        @_,
        {
            id => { type=>SCALAR },

            handler_family => { type=>SCALAR },
            handler_class  => { type=>SCALAR, optional=>1, default=>q{*} },
            handler_action => { type=>SCALAR, optional=>1, default=>q{*} },

            handler_object => { type=>SCALAR, optional=>1, default=>q{*} },

            policy => { type=>SCALAR },

            _debug => { type=>SCALAR, optional=>1 },
        }
    );

    SLight::Core::DB::run_insert(
        into    => q{User_Access},
        values  => {
            User_id => $P{'id'},

            handler_family => $P{'handler_family'},
            handler_class  => $P{'handler_class'},
            handler_action => $P{'handler_action'},

            handler_object => $P{'handler_object'},

            policy => $P{'policy'},
        },
        debug   => $P{'_debug'},
    );

    return;
} # }}}

sub set_System_access { # {{{
    my %P = validate(
        @_,
        {
            type => { type=>SCALAR },

            handler_family => { type=>SCALAR },
            handler_class  => { type=>SCALAR, optional=>1, default=>q{*} },
            handler_action => { type=>SCALAR, optional=>1, default=>q{*} },

            policy => { type=>SCALAR },

            _debug => { type=>SCALAR, optional=>1 },
        }
    );

    SLight::Core::DB::run_insert(
        into    => q{System_Access},
        values  => {
            user_type => $P{'type'},

            handler_family => $P{'handler_family'},
            handler_class  => $P{'handler_class'},
            handler_action => $P{'handler_action'},

            policy => $P{'policy'},
        },
        debug   => $P{'_debug'},
    );

    return;
} # }}}

sub clear_User_access { # {{{
    my %P = validate(
        @_,
        {
            id => { type=>SCALAR },

            handler_family => { type=>SCALAR },
            handler_class  => { type=>SCALAR, optional=>1, default=>q{*} },
            handler_action => { type=>SCALAR, optional=>1, default=>q{*} },

            handler_object => { type=>SCALAR, optional=>1, default=>q{*} },

            _debug => { type=>SCALAR, optional=>1 },
        }
    );

    my @where = ( q{User_id = }, $P{'id'} );
    foreach my $field (qw( handler_family handler_class handler_action )) {
        push @where, q{ AND } . $field . q{ = }, $P{$field},
    }

    SLight::Core::DB::run_delete(
        from    => q{User_Access},
        where   => \@where,
        debug   => $P{'_debug'},
    );

    return;
} # }}}

sub clear_System_access { # {{{
    my %P = validate(
        @_,
        {
            type => { type=>SCALAR },

            handler_family => { type=>SCALAR },
            handler_class  => { type=>SCALAR, optional=>1, default=>q{*} },
            handler_action => { type=>SCALAR, optional=>1, default=>q{*} },

            _debug => { type=>SCALAR, optional=>1 },
        }
    );

    my @where = ( q{user_type = }, $P{'type'} );
    foreach my $field (qw( handler_family handler_class handler_action )) {
        push @where, q{ AND } . $field . q{ = }, $P{$field},
    }

    SLight::Core::DB::run_delete(
        from    => q{System_Access},
        where   => \@where,
        debug   => $P{'_debug'},
    );

    return;
} # }}}


sub can_User_access { # {{{
    my %P = validate(
        @_,
        {
            id => { type=>SCALAR | UNDEF, optional=>1, },

            handler_family => { type=>SCALAR },
            handler_class  => { type=>SCALAR },
            handler_action => { type=>SCALAR },

            handler_object => { type=>SCALAR | UNDEF },

            _debug => { type=>SCALAR, optional=>1 },
        }
    );

    # Errors are always allowed to be viewed :)
    if ($P{'handler_family'} eq 'Error') {
        return q{GRANTED};
    }

    # FIXME! Cache response from this function, or it will be awfully slow!

    my @system_wild_path = (
        { type => 'System', handler_family => $P{'handler_family'}, handler_class  => $P{'handler_class'}, handler_action => $P{'handler_action'}, },
        { type => 'System', handler_family => $P{'handler_family'}, handler_class  => $P{'handler_class'}, handler_action => q{*}, },
        { type => 'System', handler_family => $P{'handler_family'}, handler_class  => q{*},                handler_action => q{*}, },
    );
    if ($P{'id'}) {
        push @system_wild_path, { type => 'Authenticated', handler_family => $P{'handler_family'}, handler_class  => $P{'handler_class'}, handler_action => $P{'handler_action'}, };
        push @system_wild_path, { type => 'Authenticated', handler_family => $P{'handler_family'}, handler_class  => $P{'handler_class'}, handler_action => q{*}, };
        push @system_wild_path, { type => 'Authenticated', handler_family => $P{'handler_family'}, handler_class  => q{*},                handler_action => q{*}, };
    }
    else {
        push @system_wild_path, { type => 'Guest', handler_family => $P{'handler_family'}, handler_class  => $P{'handler_class'}, handler_action => $P{'handler_action'}, };
        push @system_wild_path, { type => 'Guest', handler_family => $P{'handler_family'}, handler_class  => $P{'handler_class'}, handler_action => q{*}, };
        push @system_wild_path, { type => 'Guest', handler_family => $P{'handler_family'}, handler_class  => q{*},                handler_action => q{*}, };
    }

    my $found_granted = 0;
    foreach my $path (@system_wild_path) {
        my $system_access = get_System_access(
            %{ $path },
        );
        if ($system_access and $system_access eq 'DENIED') {
            return q{DENIED};
        }
        elsif ($system_access and $system_access eq 'GRANTED') {
            $found_granted = 1;
        }
    }

    if ($found_granted) {
        return q{GRANTED};
    }

    if ($P{'id'}) {
        my @user_wild_path = (
            { id => $P{'id'}, handler_family => $P{'handler_family'}, handler_class  => $P{'handler_class'}, handler_action => $P{'handler_action'}, handler_object => $P{'handler_object'} },
            { id => $P{'id'}, handler_family => $P{'handler_family'}, handler_class  => $P{'handler_class'}, handler_action => $P{'handler_action'}, handler_object => q{*} },
            { id => $P{'id'}, handler_family => $P{'handler_family'}, handler_class  => $P{'handler_class'}, handler_action => q{*},                 handler_object => q{*} },
            { id => $P{'id'}, handler_family => $P{'handler_family'}, handler_class  => q{*},                handler_action => q{*},                 handler_object => q{*} },
        );

        if (not defined $P{'handler_object'}) {
            shift @user_wild_path;
        }

        $found_granted = 0;
        foreach my $path (@user_wild_path) {
            my $system_access = get_User_access(%{ $path });

            if ($system_access and $system_access eq 'DENIED') {
                return 'DENIED';
            }
            elsif ($system_access and $system_access eq 'GRANTED') {
                $found_granted = 1;
            }
        }
    }

    if ($found_granted) {
        return q{GRANTED};
    }

    return 'DENIED';
} # }}}

# vim: fdm=marker
1;
