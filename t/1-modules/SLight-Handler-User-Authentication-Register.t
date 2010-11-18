#!/usr/bin/perl
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
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use SLight::API::User qw( get_Users_where );
use SLight::Core::Session;
use SLight::Test::Site;
use SLight::Test::Handler qw( run_handler_tests );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

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
            q{u-user}  => 'Fooley',
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
        'name' => q{Display 'Thank you' page},
        'url'  => q{/_Authentication/Register-thankyou.web},
    },
);

run_handler_tests(
    tests => \@tests,
);

# vim: fdm=marker
