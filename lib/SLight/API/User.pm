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
use base 'Exporter';

use SLight::Core::Entity;

use Carp::Assert::More qw( assert_exists );
use Digest::SHA qw( sha512_hex );
use Params::Validate qw( :all );
# }}}

our @EXPORT_OK = qw(
    add_User
    update_User
    get_User
    delete_User
    is_User_registered
    check_User_pass
);
our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

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

#    has_owner    => 1,
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

sub update_User { # {{{
    my %P = validate (
        @_,
        {
            id => { type=>SCALAR },

            name   => { type=>SCALAR, optional=>1 },
            pass   => { type=>SCALAR, optional=>1 },
            status => { type=>SCALAR, optional=>1 },
            email  => { type=>SCALAR, optional=>1 },
        }
    );
    
    # Encrypt password, before putting it into DB.
    if ($P{'pass'}) {
        $P{'pass_enc'} = sha512_hex(delete $P{'pass'});
    }

    # Get or assign ID of the email:
    if ($P{'email'}) {
        $P{'email_id'} = SLight::Core::Email::get_email_id(delete $P{'email'}, 1);
    }

    return $_handler->update_ENTITY(
        %P,
    );
} # }}}

sub get_User { # {{{
} # }}}

sub delete_User { # {{{
} # }}}

sub is_User_registered { # {{{
    my ( $login ) = @_;

    if ($_handler->count_ENTITYs_where( login=>$login )) {
        return 1;
    }

    return
} # }}}

sub check_User_pass { # {{{
} # }}}

# vim: fdm=marker
1;
