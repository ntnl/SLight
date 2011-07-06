package SLight::Maintenance::Daily;
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

our $VERSION = 0.0.5;

use Carp::Assert::More qw( assert_defined );
use Params::Validate qw( :all );
# }}}

sub new { # {{{
    my ($class) = @_;

    my $self = {
    };

    bless $self, $class;

    return $self;
} # }}}

sub main { # {{{
    # Dev note:
    #   Hardcoded, but in future can be dynamic or even configurable.

    require SLight::Maintenance::Daily::Sessions;

    SLight::Maintenance::Daily::Sessions::run();

    return 0;
} # }}}

# vim: fdm=marker
1;
