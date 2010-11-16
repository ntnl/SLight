package SLight::Test::Addon;
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
use base 'Exporter';
our @EXPORT_OK = qw(
    run_addon_tests
);
our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);

use SLight::AddonFactory;
use SLight::Core::Session;
use SLight::Core::URL;
use SLight::Test::Runner qw( run_tests );

use Carp::Assert::More qw( assert_defined assert_listref );
use Params::Validate qw( :all );
# }}}

sub run_addon_tests { # {{{
    my %P = validate(
        @_,
        {
            tests => { type=>ARRAYREF },

            addon => { type=>SCALAR },

            call_before => { type=>CODEREF, optional=>1 },
            call_format => { type=>CODEREF, optional=>1 },
            call_result => { type=>CODEREF, optional=>1 },
        }
    );

    my $factory = SLight::AddonFactory->new();

    my ( $addon_pkg, $addon_class ) = split q{::}, delete $P{'addon'};

    my @tests;
    foreach my $t (@{ $P{'tests'} }) {
        my %runner_test = (
            name     => $t->{'name'},
            expect   => ( $t->{'expect'} or 'hashref' ),
            callback => \&_run_test,
            args     => [
                $t,
                $factory->make( pkg => $addon_pkg, addon => $addon_class ),
            ],
        );

        push @tests, \%runner_test;
    }

    return run_tests(
        %P,

        tests => \@tests,
    );
} # }}}

sub _run_test { # {{{
    my ( $t, $addon ) = @_;

    # Drop any remaining connection.
    # Request has to be able to re-connect by itself.
    SLight::Core::DB::disconnect();
    
    # Drop any remaining connection.
    # Request has to be able to re-connect by itself.
    SLight::Core::DB::disconnect();

    if ($t->{'session'}) {
        SLight::Core::Session::drop();

        SLight::Core::Session::start();

        foreach my $part (keys %{ $t->{'session'} }) {
            SLight::Core::Session::part_set($part, $t->{'session'}->{$part});
        }
    }

    my $url = SLight::Core::URL::parse_url($t->{'url'});

    return $addon->process(
        user    => ( SLight::Core::Session::part('user') or {} ),
        url     => $url,
        page_id => $t->{'page_id'},
        meta    => $t->{'meta'},
    );
} # }}}

# vim: fdm=marker
1;
