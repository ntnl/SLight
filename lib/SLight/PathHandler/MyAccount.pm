package SLight::PathHandler::MyAccount;
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
use base q{SLight::PathHandlerBase::SubClass};

# }}}

# FIXME: Check, if User has authenticated, and has proper status!

sub default_class { # {{{
    return 'MyAccount::MyData';
} # }}}

sub class_base { # {{{
    return 'MyAccount';
} # }}}

# vim: fdm=marker
1;
