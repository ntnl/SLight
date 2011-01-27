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

my @tests = (
    {
        'name' => q{User registration form},
        'url'  => q{/_Authentication/Register.web},
    },
    {
        'name' => q{Send out bad data (crash test)},
        'url'  => q{/_Authentication/Register-request.web},
        'cgi'  => {
            q{u-pass}        => 'Foo',
            q{u-pass-repeat} => 'Bar',
        }
    },
    {
        'name' => q{Send out the form},
        'url'  => q{/_Authentication/Register-request.web},
        'cgi'  => {
            q{u-login} => 'Fooley',
            q{u-name}  => 'Test subject',
            q{u-email} => 'test@subject.test',

            q{u-pass}        => 'MojeHasło', # Means: My Password (polish)
            q{u-pass-repeat} => 'MojeHasło',
        }
    },
    {
        'name'     => q{Check: User account was created},
        'callback' => sub {
            return get_Users_where(
                login => 'Fooley',
            );
        },
        expect => 'arrayref',
    },
    {
        'name'     => q{Check: Confirmation email was sent},
        'callback' => sub {
            return $SLight::Core::Email::_unsent_stack[0]->{'Parts'};
        },
        expect => 'arrayref',
    },
    {
        'name'     => q{Check: EVK was set-up.},
        'callback' => sub {
            return get_EVK(1);
        },
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


package Data::UUID;
my $ct = 0;

no warnings;

sub to_string { # {{{
    $ct++;

# Some valid UUIDs:
#    4162F712-1DD2-11B2-B17E-C09EFE1DC403
#    2BC9E9A0-F3E7-11DF-91F2-D6145CFB52DF

    my $fake_id = uc sprintf q{%08x-%04x-%04x-%04x-%012x}, 333*$ct, 22*$ct, $ct, 22*$ct, 4444*$ct;

    return $fake_id;
} # }}}

# vim: fdm=marker
