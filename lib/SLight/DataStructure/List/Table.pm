package SLight::DataStructure::List::Table;
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
use base 'SLight::DataStructure::List';

use Params::Validate qw( :all );
# }}}

# Initialize the GenericTable.
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

    # Todo: make header!

    $self->{'TableContent'} = [];

    $self->{'Columns'} = $P{'columns'};

    $self->set_data(
        $self->make_Table(
            class   => $P{'class'},
            content => $self->{'TableContent'},
        )
    );

    return;
} # }}}

sub add_Row { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class => { type=>SCALAR, optional=>1, default=>'generic' },
            data  => { type=>HASHREF },
        }
    );
    
#    use Data::Dumper; warn Dumper $P{'data'};

    my @columns;
    foreach my $column (@{ $self->{'Columns'} }) {
        my $content = $self->make_label_if_text(
            object => $P{'data'}->{ $column->{'name'} },
            class  => $column->{'name'}
        );

        push @columns, $self->make_TableCell(
            class   => $column->{'name'},
            content => $content,
        );
    }

    push @{ $self->{'TableContent'} }, $self->make_TableRow(
        class   => $P{'class'},
        content => \@columns,
    );

    return;
} # }}}

# vim: fdm=marker
1;
