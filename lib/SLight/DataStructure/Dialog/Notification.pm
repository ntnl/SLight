package SLight::DataStructure::Dialog::Notification;
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

use strict; use warnings;
use base 'SLight::DataStructure::Dialog';

use Carp qw( confess );

sub add_button { # {{{
    return confess("Notification does not have buttons!");
} # }}}

# vim: fdm=marker
1;
