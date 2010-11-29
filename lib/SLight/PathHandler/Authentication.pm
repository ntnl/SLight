package SLight::PathHandler::Authentication;
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
use base q{SLight::PathHandlerBase::Single};

# }}}

sub object_class { # {{{
    return q{User::Authentication};
} # }}}

# vim: fdm=marker
1;
