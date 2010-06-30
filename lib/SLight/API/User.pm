package SLight::API::User;
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

use SLight::Core::Entity;

use Carp::Assert::More qw( assert_exists );
use Digest::SHA qw( sha512_hex );
use Params::Validate qw( :all );
# }}}

my %meta = (
    all_fields  => [qw( id login name pass email )],
    data_fields => [qw(    login name      email )],
);

my %status_set = (
    'Disabled',
        # User account exists, but is not usable
        # This User can not log in.
        #
    'Guest',
        # User account exists, but must be verified before it becomes fully usable
        # This User can log in, but is othervise same as Guest (hence the name)
        # Does not have to enter his Email all the time, as normal guests do.
        #
    'Enabled',
        # Fully-usable User account.
);

sub add_user { # {{{
    my %P = validate (
        @_,
        {
            login  => { type=>SCALAR },
            name   => { type=>SCALAR, optional=>1 },
            pass   => { type=>SCALAR },
            status => { type=>SCALAR },

            email     => { type=>SCALAR },
            email_key => { type=>SCALAR, optional=>1 },
        }
    );

    assert_exists(\%status_set, $P{'status'}, 'Status is supported');

    # Encrypt password, before putting it into DB.
    my $pass_enc = sha512_hex($P{'pass');

    # Get or assign ID of the email:
    my $email_id = ...

    return SLight::Core::Entity::add_ENTITY(
        id => $P{'id'},

        login  => $P{'login'},
        status => $P{'status'},
        
        name      => $P{'name'},
        email_key => $P{'email_key'},

        pass_enc => $pass_enc,
        email_id => $email_id,

        _fields => $meta{'data_fields'},
        _table  => 'User_Entity',
    );
} # }}}

# vim: fdm=marker
1;
