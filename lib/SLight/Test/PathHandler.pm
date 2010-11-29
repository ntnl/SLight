package SLight::Test::PathHandler;
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
use base 'Exporter';
our @EXPORT_OK = qw(
    run_pathhandler_tests
);
our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);

use SLight::PathHandlerFactory;
use SLight::Core::URL;
use SLight::Test::Runner qw( run_tests );

use Carp::Assert::More qw( assert_defined assert_listref );
use Params::Validate qw( :all );
use YAML::Syck qw( Dump Load );
# }}}

sub run_pathhandler_tests { # {{{
    my %P = validate(
        @_,
        {
            tests => { type=>ARRAYREF },
            
            ph => { type=>SCALAR },

            call_before => { type=>CODEREF, optional=>1 },
            call_format => { type=>CODEREF, optional=>1 },
            call_result => { type=>CODEREF, optional=>1 },
        }
    );

    my $factory = SLight::PathHandlerFactory->new();

    my $default_path_handler = delete $P{'ph'};

    my @tests;
    foreach my $t (@{ $P{'tests'} }) {
        my %runner_test = (
            name     => $t->{'name'},
            expect   => 'hashref',
            callback => \&_run_test,
            args     => [
                $t,
                $factory->make( handler => ( $t->{'ph'} or $default_path_handler ) ),
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
    my ( $t, $handler ) = @_;

    # Drop any remaining connection.
    # Request has to be able to re-connect by itself.
    SLight::Core::DB::disconnect();

    assert_listref($t->{'path'}, "Path is an ARRAY ref");

    return $handler->analyze_path($t->{'path'});
} # }}}

# vim: fdm=marker
1;
