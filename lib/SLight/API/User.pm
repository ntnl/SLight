package SLight::API::User;
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

use SLight::Core::Entity;

use Carp::Assert qw( assert );
use Carp::Assert::More qw( assert_exists assert_defined );
use Digest::SHA qw( sha512_hex );
use Params::Validate qw( :all );
# }}}

our @EXPORT_OK = qw(
    add_User
    update_User
    delete_User

    get_User
    get_User_by_login
    get_Users
    get_all_Users
    get_User_ids_where
    get_Users_where

    is_User_registered
    check_User_pass
);
our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

my %status_set = (
    'Disabled' => 1,
        # User account exists, but is not usable
        # This User can not log in.
        #
    'Guest' => 2,
        # User account exists, but must be verified before it becomes fully usable.
        # This User can log in, but is otherwise same as Guest (hence the name).
        # Does not have to enter his Email all the time, as normal guests do.
        # Such accounts are created by Authenticate-Register action.
        #
    'Enabled' => 3,
        # Fully-usable User account.
);

my $_handler = SLight::Core::Entity->new( # {{{
    base_table => 'User_Entity',

    data_fields => [qw( login status name pass_enc avatar_Asset_id )],

    has_owner => 1,

#    has_assets   => 1,
#    has_comments => 1,
); # }}}

sub add_User { # {{{
    my %P = validate (
        @_,
        {
            login  => { type=>SCALAR },
            name   => { type=>SCALAR, optional=>1 },
            pass   => { type=>SCALAR },
            status => { type=>SCALAR },

            email => { type=>SCALAR },

            avatar_Asset_id => { type=>SCALAR, optional=>1 },
        }
    );

    assert_exists(\%status_set, $P{'status'}, 'Status is supported');

    # Encrypt password, before putting it into DB.
    my $pass_enc = sha512_hex($P{'pass'});

    return $_handler->add_ENTITY(
        id => $P{'id'},

        email  => $P{'email'},
        login  => $P{'login'},
        status => $P{'status'},

        name      => $P{'name'},

        pass_enc => $pass_enc,
    );
} # }}}

sub update_User { # {{{
    my %P = validate (
        @_,
        {
            id => { type=>SCALAR },

            pass   => { type=>SCALAR, optional=>1 },
            status => { type=>SCALAR, optional=>1 },
            email  => { type=>SCALAR, optional=>1 },

            name            => { type=>SCALAR | UNDEF, optional=>1 },
            avatar_Asset_id => { type=>SCALAR | UNDEF, optional=>1 },

            _debug => { type=>SCALAR, optional=>1 },
        }
    );

    # Encrypt password, before putting it into DB.
    if ($P{'pass'}) {
        $P{'pass_enc'} = sha512_hex(delete $P{'pass'});
    }

    return $_handler->update_ENTITY(
        %P,
    );
} # }}}

sub get_User { # {{{
    my $user = $_handler->get_ENTITY(@_);

    if ($user) {
        delete $user->{'pass_enc'};
    }

    return $user;
} # }}}

# Purpose:
#   Utility method, that wraps get_Users_where for ease of API use.
sub get_User_by_login { # {{{
    my ( $login ) = @_;

    assert_defined($login, 'login given');
    assert(scalar @_ == 1, 'just login');

    my $users = $_handler->get_ENTITYs_where(
        login => $login,
    );

    if (not $users) {
        return;
    }

    if (not $users->[0]) {
        return;
    }

    my $user = $users->[0];

    delete $user->{'pass_enc'};

    return $user;
} # }}}

sub get_Users { # {{{
    my $users = $_handler->get_ENTITYs(@_);

    if ($users) {
        foreach my $user (@{ $users }) {
            delete $user->{'pass_enc'};
        }
    }

    return $users;
} # }}}

# FIXME: update automated test.
sub get_all_Users { # {{{
    my $users = $_handler->get_all_ENTITYs(@_);

    if ($users) {
        foreach my $user (@{ $users }) {
            delete $user->{'pass_enc'};
        }
    }

    return $users;
} # }}}

sub get_User_ids_where { # {{{
    return $_handler->get_ENTITY_ids_where(@_);
} # }}}

sub get_Users_where { # {{{
    my $users = $_handler->get_ENTITYs_where(@_);

    if ($users) {
        foreach my $user (@{ $users }) {
            delete $user->{'pass_enc'};
        }
    }

    return $users;
} # }}}

sub delete_User { # {{{
    return $_handler->delete_ENTITY(@_);
} # }}}

sub is_User_registered { # {{{
    my ( $login ) = @_;

    if ($_handler->count_ENTITYs_where( login=>$login )) {
        return 1;
    }

    return 0;
} # }}}

sub check_User_pass { # {{{
    my ( $login, $passwd ) = @_;

    assert_defined($login);
    assert_defined($passwd);

    my $users = $_handler->get_ENTITYs_fields_where(
        _fields => [qw( pass_enc )],

        login => $login,
    );

    if ($users and $users->[0] and ref $users eq 'ARRAY' and sha512_hex($passwd) eq $users->[0]->{'pass_enc'}) {
        return $users->[0]->{'id'};
    }

    return 0;
} # }}}

# vim: fdm=marker
1;
