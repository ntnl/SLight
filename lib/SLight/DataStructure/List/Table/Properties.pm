package SLight::DataStructure::List::Table::Properties;
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

# Response made of a generic Properties listing.
use strict; use warnings; # {{{
use base 'SLight::DataStructure::List::Table';

use Params::Validate qw( :all );
# }}}

sub _new { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            caption => { type=>SCALAR, optional=>1, },
            class   => { type=>SCALAR, optional=>1, default=>'details', },
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
        push @{ $self->{'rows'} }, $self->make_Label(
            class => 'caption',
            text  => $P{'caption'}
        );
    }

    return;
} # }}}

sub add_property { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class   => { type=>SCALAR, optional=>1, },
            caption => { type=>SCALAR },
            value   => { type=>SCALAR, optional=>1, default=>q{} }, # In future, it should accept Widgets too :)

            # Extra fills the third 'column'.
            # It should be a link, that provides extra info related to the property
            extra_caption => { type=>SCALAR, optional=>1, default=>q{More...}},
            extra_link    => { type=>SCALAR, optional=>1, },
        }
    );

    my @items;

    push @items, $self->make_Label(
        class => 'caption',
        text  => $P{'caption'}
    );
    push @items, $self->make_Label(
        class => 'value',
        text  => $P{'value'}
    );
    if ($P{'extra_link'}) {
        push @items, $self->make_Link(
            class   => 'extra_link',
            text    => $P{'caption'},
            href    => $P{'extra_link'}
        );
    }

    push @{ $self->{'rows'} }, $self->make_Container(
        class   => $P{'class'},
        content => \@items,
    );

    return;
} # }}}

# vim: fdm=marker
1;
