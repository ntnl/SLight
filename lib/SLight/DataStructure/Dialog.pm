package SLight::DataStructure::Dialog;
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
use base 'SLight::DataStructure';

use SLight::DataToken qw( mk_Label_token mk_Action_token mk_Container_token );

use Params::Validate qw( :all );
# }}}

sub _new { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            text  => { type=>SCALAR | ARRAYREF },
            class => { type=>SCALAR, optional=>1, default=>'SLight_Dialog' },
        }
    );

    $self->init_dialog($P{'class'});

    $self->add_text($P{'text'});

    return;
} # }}}

sub init_dialog { # {{{
    my ( $self, $class ) = @_;

    $self->{'Dialog'}->{'Text'}    = [];
    $self->{'Dialog'}->{'Buttons'} = [];

    my $content = [
        mk_Container_token(
            class   => 'Message',
            content => $self->{'Dialog'}->{'Text'},
        ),
        mk_Container_token(
            class   => 'Buttons',
            content => $self->{'Dialog'}->{'Buttons'},
        ),
    ];

    $self->set_data(
        mk_Container_token(
            class   => $class,
            content => $content,
        ),
    );

    return;
} # }}}

sub add_text { # {{{
    my ( $self, $text ) = @_;

    push @{ $self->{'Dialog'}->{'Text'} }, mk_Label_token(
        text => $text,
    );

    return;
} # }}}

sub add_button { # {{{
    my ( $self, %P ) = @_;

    # FIXME: validate input!

    push @{ $self->{'Dialog'}->{'Buttons'} }, mk_Action_token(
        class   => ( $P{'class'} or 'generic' ),
        caption => $P{'caption'},
        href    => $P{'href'},
    );

    return;
} # }}}

# vim: fdm=marker
1;

