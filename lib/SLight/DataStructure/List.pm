package SLight::DataStructure::List;
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
use base 'SLight::DataStructure';

use Params::Validate qw( :all );
# }}}

# Initialize the Generic List.
# Columns: [
#   {
#       caption => text,
#       name    => text,
#   },
#   ...
# ]
sub _new { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class   => { type=>SCALAR, optional=>1, default=>'generic' },
            columns => { type=>ARRAYREF },
        }
    );

    $self->{'Items'} = [];

    $self->{'Columns'} = $P{'columns'};

    $self->set_data(
        $self->make_Grid(
            class   => $P{'class'},
            content => $self->{'Items'},
        )
    );

    return;
} # }}}

sub add_Item { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class => { type=>SCALAR, optional=>1, default=>'generic' },
            data  => { type=>HASHREF },
        }
    );
    
#    use Data::Dumper; warn Dumper $P{'data'};

    my @fields;
    foreach my $column (@{ $self->{'Columns'} }) {
        push @fields, @{
            $self->make_label_if_text(
                object => $P{'data'}->{ $column->{'name'} },
                class  => $column->{'name'}
            )
        };
    }

    push @{ $self->{'Items'} }, $self->make_GridItem(
        class   => $P{'class'},
        content => \@fields,
    );

    return;
} # }}}

# vim: fdm=marker
1;