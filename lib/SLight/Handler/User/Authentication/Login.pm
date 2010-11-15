package SLight::Handler::User::Authentication::Login;
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

use SLight::API::User qw( check_User_pass get_User );
use SLight::Core::L10N qw( TR TF );
use SLight::Core::Session;
use SLight::HandlerUtils::LoginForm;
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_Login_Form');

    my $form = SLight::HandlerUtils::LoginForm::build(
        q{/}, # Page-version of login form redirects to main page. Always.
        $self->{'options'},
        {}
    );

    return $self->push_data($form);
} # }}}

sub handle_authenticate { # {{{
    my ($self, $oid, $metadata ) = @_;

    my $user_id = check_User_pass($self->{'options'}->{'user'}, $self->{'options'}->{'pass'});

    if (not $user_id) {
        # Return form, with an error!
        # ...
    }

    my $user = get_User($user_id);

    my %user_hash = (
        login => $user->{'login'},
    );
    SLight::Core::Session::part_set(
        'user',
        \%user_hash
    );

    $self->set_redirect(
        $self->build_url(
            path_handler => 'Page',
            path         => [],

            action => 'View',
            step   => 'view'
        ),
    );

    return;
} # }}}

# vim: fdm=marker
1;
