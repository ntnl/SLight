#!/usr/bin/perl
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
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use SLight::API::User qw( get_Users_where );
use SLight::API::EVK qw( get_EVK );
use SLight::Core::Email;
use SLight::Core::Session;
use SLight::Test::Site;
use SLight::Test::Handler qw( run_handler_tests );

use Data::UUID;
use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

# Sending REAL emails in automated tests does not seem to be smart ;)
SLight::Core::Email::debug_disable_sending();

my $cgi_1 = {
    key   => undef,
    login => q{Fooley},
};

my @tests = (
    {
        'name' => q{Register an User account},
        'url'  => q{/_Authentication/Register-request.web},
        'cgi'  => {
            q{u-login} => 'Fooley',
            q{u-name}  => 'Test subject',
            q{u-email} => 'test@subject.test',

            q{u-pass}        => 'MojeHasło', # Means: My Password (polish)
            q{u-pass-repeat} => 'MojeHasło',
        },

        'call_after' => sub {
            my $evk = get_EVK(1);

            $cgi_1->{key} = $evk->{'key'};
        },
    },
    {
        'name'     => q{Check: User account before activation},
        'callback' => sub {
            return get_Users_where(
                login => 'Fooley',
            );
        },
        expect => 'arrayref',
    },
    {
        'name' => q{Try to activate fake account},
        'url'  => q{/_Authentication/ActivateAccount.web},
        'cgi'  => {
            key   => q{12345678-1234-1234-1234-1234567890AB},
            login => q{Boobey},
        },
    },
    {
        'name' => q{Activate real account},
        'url'  => q{/_Authentication/ActivateAccount.web},
        'cgi'  => $cgi_1,
    },
    {
        # This should result in 'incorrect activation key',
        # since keys are deleted once the account is activated, thus can not be used again.
        'name' => q{Activate already active account},
        'url'  => q{/_Authentication/ActivateAccount.web},
        'cgi'  => $cgi_1,
    },
    {
        'name'     => q{Check: User account after activation},
        'callback' => sub {
            return get_Users_where(
                login => 'Fooley',
            );
        },
        expect => 'arrayref',
    },
    {
        'name' => q{Display 'Thank you' page},
        'url'  => q{/_Authentication/Register-thankyou.web},
    },
);

run_handler_tests(
    tests => \@tests,

    skip_permissions => 1,
);

# vim: fdm=marker
