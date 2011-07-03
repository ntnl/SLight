package SLight::PathHandler::MyAccount;
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
use base q{SLight::PathHandlerBase::SubClass};

# }}}

sub default_class { return 'MyAccount::MyData'; }

sub class_base { return 'MyAccount'; }

sub template_name { return 'MyAccount'; }

# vim: fdm=marker
1;
