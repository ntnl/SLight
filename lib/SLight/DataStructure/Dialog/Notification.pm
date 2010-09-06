package SLight::DataStructure::Dialog::Notification;
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

sub _new { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            text  => { type=>SCALAR },
            class => { type=>SCALAR, optional=>1, default=>'Message' },
        }
    );

    $self->set_data(
        $self->make_Label(
            class => $P{'class'},
            text  => $P{'text'},
        ),
    );

    return;
} # }}}

# vim: fdm=marker
1;

