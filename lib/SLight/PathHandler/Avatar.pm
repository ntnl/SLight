package SLight::PathHandler::Avatar;
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
use base q{SLight::PathHandlerBase::Single};

# }}}

sub object_class { # {{{
    return q{User::Avatar};
} # }}}

# vim: fdm=marker
1;
