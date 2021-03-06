package SLight::Handler::Core::Empty::AddContent;
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
use base q{SLight::HandlerBase::ProxyAction};
# }}}

# This is just a proxy action for SLight::Handler::CMS::Entry::AddContent.

sub target_object { return q{CMS::Entry}; }

# vim: fdm=marker
1;
