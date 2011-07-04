package SLight::DataStructure::Properties;
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

# Response made of a generic Properties listing.
use strict; use warnings; # {{{
use base 'SLight::DataStructure::List::Table';

use SLight::DataToken qw( mk_Label_token mk_Link_token mk_Container_token );

use Params::Validate qw( :all );
# }}}

sub _new { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            caption => { type=>SCALAR, optional=>1, },
            class   => { type=>SCALAR, optional=>1, default=>'SL_Properties', },
        }
    );

    $self->{'rows'} = [];

    $self->set_data(
        {
            type    => 'Container',
            data    => { },
            content => $self->{'rows'},
            class   => $P{'class'},
        }
    );

    if ($P{'caption'}) {
        push @{ $self->{'rows'} }, mk_Label_token(
            class => 'caption',
            text  => $P{'caption'}
        );
    }

    return;
} # }}}

sub add_Property { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class   => { type=>SCALAR, optional=>1, default=>'default' },
            caption => { type=>SCALAR },
            value   => { type=>SCALAR, optional=>1, default=>q{} }, # In future, it should accept Widgets too :)

            # Extra fills the third 'column'.
            # It should be a link, that provides extra info related to the property
            extra_caption => { type=>SCALAR, optional=>1, default=>q{More...}},
            extra_link    => { type=>SCALAR, optional=>1, },
        }
    );

    my @items;

    push @items, mk_Label_token(
        class => 'SL_Property_Caption',
        text  => $P{'caption'}
    );
    push @items, mk_Label_token(
        class => 'SL_Property_Value',
        text  => $P{'value'}
    );
    if ($P{'extra_link'}) {
        push @items, mk_Link_token(
            class   => 'SL_Property_Link',
            text    => $P{'caption'},
            href    => $P{'extra_link'}
        );
    }

    push @{ $self->{'rows'} }, mk_Container_token(
        class   => $P{'class'},
        content => \@items,
    );

    return;
} # }}}

# vim: fdm=marker
1;
