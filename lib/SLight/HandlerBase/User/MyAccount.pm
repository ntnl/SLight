package SLight::HandlerBase::User::MyAccount;
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

use SLight::API::User qw( get_User );
use SLight::DataStructure::Dialog::Notification;
use SLight::Core::L10N qw( TR TF );
# }}}

sub get_user_data { # {{{
    my ( $self ) = @_;

#    use Data::Dumper; warn "User in handler: ". Dumper $self->{'user'};

    if ($self->{'user'}->{'id'}) {
        my $user = get_User($self->{'user'}->{'id'});

        if ($user->{'status'} eq 'Disabled') {
            my $message = SLight::DataStructure::Dialog::Notification->new(
                text => TR("This Account is disabled."),
            );

            $self->push_data($message);

            return;
        }

        return $user;
    }

    # Return AuthRequired error by doing internal redirect!
    $self->replace_with_object(
        class    => q{Error::AuthRequired},
        oid      => undef,
        metadata => {},
    );

    return;
} # }}}

# vim: fdm=marker
1;
