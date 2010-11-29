package SLight::API::EVK;
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

use SLight::Core::Entity;

use Params::Validate qw( :all );
# }}}

our @EXPORT_OK = qw(
    add_EVK
    update_EVK
    delete_EVK
    get_EVK
    get_EVK_by_key
);
our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

my $_handler = SLight::Core::Entity->new( # {{{
    base_table  => 'Email_Verification_Key',

    data_fields => [qw( id key )],

    has_metadata => 1,
    has_owner => 1,
); # }}}

sub add_EVK { # {{{
    my %P = validate (
        @_,
        {
            email => { type=>SCALAR },
            key   => { type=>SCALAR },
            
            metadata => { type=>HASHREF, optional=>1 },
        }
    );

    return $_handler->add_ENTITY(%P);
} # }}}

sub update_EVK { # {{{
    my %P = validate (
        @_,
        {
            id => { type=>SCALAR },

            email    => { type=>SCALAR, optional=>1 },
            key      => { type=>SCALAR, optional=>1 },
            metadata => { type=>HASHREF, optional=>1 },
        }
    );

    return $_handler->update_ENTITY(%P);
} # }}}

sub delete_EVK { # {{{
    my ( $id ) = @_;

    return $_handler->delete_ENTITYs( [ $id ] );
} # }}}

sub get_EVK { # {{{
    my ( $id ) = @_;

    return $_handler->get_ENTITY($id);
} # }}}

sub get_EVK_by_key { # {{{
    my ( $key ) = @_;

    my $evks = $_handler->get_ENTITYs_where(
        key => $key,
    );

    if ($evks) {
        return $evks->[0];
    }

    return;
} # }}}

# vim: fdm=marker
1;
