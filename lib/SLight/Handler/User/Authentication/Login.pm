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

use SLight::API::User qw( check_User_pass );
use SLight::Core::Session;
use SLight::HandlerUtils::LoginForm;
# }}}

sub do_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_Login_Form');

    my $user_id = check_User_pass($self->{'options'}->{'user'}, $self->{'options'}->{'pass'});

    my $form = SLight::HandlerUtils::LoginForm::build(
        q{/}, # Page-version of login form redirects to main page. Always.
        {}
    );

    return $self->push_data($form);
} # }}}

sub do_authenticate { # {{{
    my ($self, @params ) = @_;

} # }}}

    return;
} # }}}

sub save_form { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_Login_Form');

    my %user_hash = (
        login => $self->{'Login'}->{'login'},
    );
    SLight::Core::Session::part_set(
        'user',
        \%user_hash
    );

    return $self->build_url(
        action => 'View',
        path   => [
            'Spec',
            $oid,
        ],
        step   => 'view'
    );
} # }}}

# vim: fdm=marker
1;
