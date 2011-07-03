package SLight::DataStructure::List;
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
use base 'SLight::DataStructure';

use SLight::DataToken qw( mk_List_token mk_Label_token mk_ListItem_token );

use Carp::Assert::More qw( assert_defined );
use Params::Validate qw( :all );
# }}}

# Initialize the Generic List.
# Columns: [
#   {
#       caption => text,
#       name    => text,
#       class   => text, # Optional
#   },
#   ...
# ]
sub _new { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            columns => { type=>ARRAYREF },

            class    => { type=>SCALAR, optional=>1 },
            captions => { type=>SCALAR, optional=>1 },
        }
    );

    $self->{'Items'} = [];

    $self->{'Columns'} = $P{'columns'};

    $self->{'captions'} = $P{'captions'};

    $self->set_data(
        $self->_make_container( $P{'class'}, $self->{'Items'} )
    );

    # Self-checks and defaults.
    foreach my $column (@{ $self->{'Columns'} }) {
        assert_defined($column->{'name'});
        assert_defined($column->{'caption'});
    }

    return;
} # }}}

sub _make_container { # {{{
    my ( $self, $class, $items ) = @_;

    my %list = (
        content => $items,
    );
    if ($class) {
        $list{'class'} = $class;
    }

    return mk_List_token(%list);
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

    my @fields;
    foreach my $column (@{ $self->{'Columns'} }) {
        if (defined $P{'data'}->{ $column->{'name'} }) {
            if ($self->{'captions'}) {
                push @fields, mk_Label_token(
                    class => 'SL_Label',
                    text  => $column->{'caption'},
                );
            }

            push @fields, @{
                $self->make_label_if_text(
                    object => $P{'data'}->{ $column->{'name'} },
                    class  => $column->{'name'}
                )
            };
        }
    }

    push @{ $self->{'Items'} }, mk_ListItem_token(
        class   => $P{'class'},
        content => \@fields,
    );

    return;
} # }}}

# vim: fdm=marker
1;
