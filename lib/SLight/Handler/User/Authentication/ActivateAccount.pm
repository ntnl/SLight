package SLight::Handler::User::Authentication::ActivateAccount;
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
use base q{SLight::Handler};

use SLight::API::EVK qw( get_EVK_by_key delete_EVK );
use SLight::API::User qw( get_User update_User );
use SLight::DataStructure::Dialog::Notification;
use SLight::Core::L10N qw( TR TF );
use SLight::HandlerUtils::UserLogin;
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_ActivateAccount_User');

    my $evk = get_EVK_by_key($self->{'options'}->{'key'});

#    use Data::Dumper; warn Dumper $evk;
#    warn "Hey! " . $self->{'options'}->{'key'};

    if ($evk and $evk->{'metadata'}->{'login'} eq $self->{'options'}->{'login'}) {
        my $user = get_User($evk->{'metadata'}->{'user_id'});

        if ($user->{'status'} eq 'Enabled') {
            my $message = SLight::DataStructure::Dialog::Notification->new(
                text => TR("The account is already active. Please log-in."),
            );

            $self->push_data($message);

            return;
        }
        elsif ($user->{'status'} eq 'Guest') {
            update_User(
                id     => $evk->{'metadata'}->{'user_id'},
                status => 'Enabled',
            );

            delete_EVK($evk->{'id'});

            # Log-in the User.
            SLight::HandlerUtils::UserLogin::login($evk->{'metadata'}->{'user_id'}, $evk->{'metadata'}->{'login'});
        }
        else {
            # Disabled account!
            my $message = SLight::DataStructure::Dialog::Notification->new(
                text => TR("This Account has been disabled, and can not be activated."),
            );

            $self->push_data($message);

            return;
        }
    }
    else {
        my $message = SLight::DataStructure::Dialog::Notification->new(
            text => TR("Given activation key is incorrect. Please check spelling. Note, that letter case is important."),
        );

        $self->push_data($message);

        return;
    }

    # Redirect to 'Thank you' page.
    my $target_url = $self->build_url(
        path_handler => 'Authentication',
        path         => [],

        action  => 'ActivateAccount',
        step    => 'thankyou',
        options => {},
    );

    $self->redirect($target_url);

    return;
} # }}}

sub handle_thankyou { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_ActivateAccount_User');

    my $message = SLight::DataStructure::Dialog::Notification->new(
        text => TR("The account is now active, and fully usable for You!"),
    );

    $self->push_data($message);

    # FIXME:
    # Auto-Log-in the User.

    return;
} # }}}

# vim: fdm=marker
1;
