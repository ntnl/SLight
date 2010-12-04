package SLight::DataStructure;
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

# Handler of generic DataStructure, and base code for specialized SataStructure objects.
use strict; use warnings; # {{{

use SLight::DataToken qw( mk_Label_token );

use Carp::Assert::More qw( assert_defined );
use Params::Validate qw( :all );
# }}}

sub new { # {{{
    my ( $class, %P ) = @_;

    my $self = {
        data => undef,
    };

    bless $self, $class;

    $self->_new(%P);

    return $self;
} # }}}

# Childs may wish to overwrite this.
sub _new { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
        }
    );

    return;
} # }}}

# Set data stored in Response handler.
sub set_data { # {{{
    my ( $self, $data ) = @_;

    # Todo: some validation would be nice.

    return $self->{'data'} = $data;
} # }}}

# Return data prepared by Response handler.
sub get_data { # {{{
    my ( $self ) = @_;
    
    assert_defined($self->{'data'}, "Data prepared.");

    return $self->{'data'};
} # }}}

# Utility functions

# If given 'object' is a scalar, make Label from it.
# Returns either one element array (scalar context) or Label hash.
#
# If it is a reference, just return it.
#
# Especially handy for making simple tables/grids or other simple elements.
sub make_label_if_text { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class  => { type=>SCALAR, optional=>1, default=>'generic' },
            object => { }
        }
    );

    if (ref $P{'object'} eq 'ARRAY') {
        return $P{'object'};
    }
    elsif (ref $P{'object'} eq 'HASH') {
        return [ $P{'object'} ];
    }

    return [
        mk_Label_token(
            text  => $P{'object'},
            class => $P{'class'}
        )
    ];
} # }}}

# vim: fdm=marker
1;
