package SLight::DataStructure::List::Table;
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
use base 'SLight::DataStructure::List';

use SLight::DataToken qw( mk_Table_token mk_TableRow_token mk_TableCell_token );

use Params::Validate qw( :all );
# }}}

sub _make_container { # {{{
    my ( $self, $class, $items ) = @_;

    my %table = (
        content => $items,
    );
    if ($class) {
        $table{'class'} = $class;
    }

    return mk_Table_token(%table);
} # }}}

sub add_Row { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class => { type=>SCALAR, optional=>1 },
            data  => { type=>HASHREF },
        }
    );

#    use Data::Dumper; warn Dumper $P{'data'};

    my @columns;
    foreach my $column (@{ $self->{'Columns'} }) {
        my $content = $self->make_label_if_text(
            object => $P{'data'}->{ $column->{'name'} },
            class  => $column->{'class'},
        );

        my %cell = (
            content => $content,
        );
        if ($column->{'class'}) {
            $cell{'class'} = $column->{'class'};
        }
        push @columns, mk_TableCell_token(%cell);
    }

    my %row = (
        content => \@columns,
    );
    if ($P{'class'}) {
        $row{'class'} = $P{'class'};
    }
    push @{ $self->{'Items'} }, mk_TableRow_token(%row);

    return;
} # }}}

# vim: fdm=marker
1;
