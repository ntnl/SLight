package SLight::Addon;
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

use Params::Validate qw{ :all };
# }}}

sub new { # {{{
    my $class = shift;
    my %P = validate(
        @_,
        {
        }
    );

    # Prototype of the object:
    my $self = {};

    bless $self, $class;

    return $self;
} # }}}

sub process { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            page_id => { type=>SCALAR },
            url     => { type=>HASHREF },
            user    => { type=>HASHREF },
            meta    => { type=>HASHREF },
        }
    );

    foreach my $key (qw( url user meta page_id )) {
        $self->{$key} = $P{$key};
    }

    return $self->_process();
} # }}}

# vim: fdm=marker
1;
