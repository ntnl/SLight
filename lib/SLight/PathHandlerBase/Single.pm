package SLight::PathHandlerBase::Single;
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
use base q{SLight::PathHandler};

# }}}

# This is a king of Path handler, that always returns one object.
#
# Is a path is given, it *should* return Not Found error!

sub analyze_path { # {{{
    my ( $self, $path ) = @_;

    my $object_class = $self->object_class();

    return 
} # }}}

# vim: fdm=marker
1;

