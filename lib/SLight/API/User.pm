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
    all_fields  => [qw( id login status name pass email_id )],
    data_fields => [qw(    login status name      email_id )],
);

my %status_set = (
    'Disabled' => 1,
        # User account exists, but is not usable
        # This User can not log in.
        #
    'Guest' => 2,
        # User account exists, but must be verified before it becomes fully usable
        # This User can log in, but is othervise same as Guest (hence the name)
        # Does not have to enter his Email all the time, as normal guests do.
        #
    'Enabled' => 3,
        # Fully-usable User account.
);

my $_handler = SLight::Core::Entity->new( # {{{
    base_table => 'User_Entity',

    data_fields => [qw( login status name pass_enc )],

    has_metadata => 1,
    has_owner    => 1,
    has_assets   => 1,
    has_comments => 1,
); # }}}

sub add_user { # {{{
    my %P = validate (
        @_,
        {
            login  => { type=>SCALAR },
            name   => { type=>SCALAR, optional=>1 },
            pass   => { type=>SCALAR },
            status => { type=>SCALAR },

            email => { type=>SCALAR },
        }
    );

    assert_exists(\%status_set, $P{'status'}, 'Status is supported');

    # Encrypt password, before putting it into DB.
    my $pass_enc = sha512_hex($P{'pass'});

    # Get or assign ID of the email:
    my $email_id = SLight::Core::Email::get_email_id($P{'email'}, 1);

    return $_handler->add_ENTITY(
        id => $P{'id'},

        login  => $P{'login'},
        status => $P{'status'},

        name      => $P{'name'},

        pass_enc => $pass_enc,
        email_id => $email_id,
    );
} # }}}

sub is_registered { # {{{
    my ( $login ) = @_;

    if ($_handler->count_ENTITYs_where( login=>$login )) {
        return 1;
    }

    return
} # }}}

# vim: fdm=marker
1;
