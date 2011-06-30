package SLight::API::UserData;
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

use SLight::Core::DB qw( SL_db_select );

use Carp::Assert::More qw( assert_defined assert_integer );
use JSON::XS;
use Params::Validate qw( :all );
# }}}

our @EXPORT_OK = qw(
    get_UserData_value
    add_UserData_value
    set_UserData_value
    update_UserData_value
    delete_UserData_value
);
our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

sub get_UserData_value { # {{{
    my ( $User_id, $Key, $_debug ) = @_;

    my $sth = SL_db_select('User_Data', [qw( data_value )], { User_id => $User_id, data_key => $Key } );

    my ( $json ) = $sth->fetchrow_array();

    if ($json) {
        my $data = decode_json($json);

        return $data->{'V'};
    }

    return;
} # }}}
sub add_UserData_value { # {{{
    my ( $User_id, $Key, $Value, $_debug ) = @_;

    assert_integer($User_id);
    assert_defined($Key);
    assert_defined($Value);

    SLight::Core::DB::check();

    SLight::Core::DB::run_insert(
        into   => 'User_Data',
        values => {
            User_id => $User_id,

            data_key   => $Key,
            data_value => encode_json({ V => $Value }),
        },
        debug  => $_debug,
    );

    return;
} # }}}
sub set_UserData_value { # {{{
    my ( $User_id, $Key, $Value, $_debug ) = @_;

    assert_integer($User_id);
    assert_defined($Key);
    assert_defined($Value);

    SLight::Core::DB::check();

    my $sth = SL_db_select('User_Data', [qw( id )], { User_id => $User_id, data_key => $Key } );

    my ( $id ) = $sth->fetchrow_array();
    if ($id) {
        SLight::Core::DB::run_update(
            table  => 'User_Data',
            set    => {
                data_value => encode_json({ V => $Value }),
            },
            where => [ 'id = ', $id ],
            debug => $_debug,
        );
    }
    else {
        SLight::Core::DB::run_insert(
            into   => 'User_Data',
            values => {
                User_id => $User_id,

                data_key     => $Key,
                data_value   => encode_json({ V => $Value }),
            },
            debug  => $_debug,
        );
    }

    return;
} # }}}
sub update_UserData_value { # {{{
    my ( $User_id, $Key, $Value, $_debug ) = @_;

    assert_integer($User_id);
    assert_defined($Key);
    assert_defined($Value);

    SLight::Core::DB::check();

    SLight::Core::DB::run_update(
        table => 'User_Data',
        set   => {
            data_value => encode_json({ V => $Value }),
        },
        where => [
            'User_id = ', $User_id,
            'AND data_key = ', $Key,
        ],
        debug => $_debug,
    );

    return;
} # }}}
sub delete_UserData_value { # {{{
    my ( $User_id, $Key, $_debug ) = @_;

    SLight::Core::DB::run_delete(
        from  => 'User_Data',
        where => [
            'User_id = ', $User_id,
            'AND data_key = ', $Key,
        ],
        debug => $_debug,
    );

    return;
} # }}}


# vim: fdm=marker
1;
