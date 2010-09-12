package SLight::Handler::Test::Foo::View;
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
use base q{SLight::Handler};

use SLight::DataStructure::Dialog::Notification;
use SLight::Core::L10N qw( TR TF );

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    return SLight::DataStructure::Dialog::Notification->new(
        class => q{SLight_Notification},
        text  => TF(q{Diagnosting message: '%s'}, undef, ($metadata->{'msg'} or 'None') ),
    );
} # }}}

# vim: fdm=marker
1;
