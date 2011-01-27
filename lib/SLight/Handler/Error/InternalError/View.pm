package SLight::Handler::Error::InternalError::View;
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
use base q{SLight::Handler};

use SLight::DataStructure::Dialog::Notification;
use SLight::Core::L10N qw( TR TF );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_Error_Internal');

    my $message = SLight::DataStructure::Dialog::Notification->new(
        text => TR("Request can not be completed, due to unexpected difficulties. Please try again. (Error: Internal)."),
    );

    $self->push_data($message);

    return;
} # }}}

# vim: fdm=marker
1;
