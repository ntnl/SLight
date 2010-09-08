package SLight::Test::Handler;
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
    run_handler_tests
);
our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);

use SLight::Core::Request;
use SLight::Core::URL;
use SLight::Test::Runner qw( run_tests );

use Carp::Assert::More qw( assert_defined );
use Params::Validate qw( :all );
# }}}

sub run_handler_tests { # {{{
    my %P = validate(
        @_,
        {
            tests => { type=>ARRAYREF },

            call_before => { type=>CODEREF, optional=>1 },
            call_format => { type=>CODEREF, optional=>1 },
            call_result => { type=>CODEREF, optional=>1 },
        }
    );

    my @tests;
    foreach my $t (@{ $P{'tests'} }) {
        my %runner_test = (
            name     => $t->{'name'},
            expect   => 'hashref',
            callback => \&_run_test,
            args     => [ $t ]
        );

        push @tests, \%runner_test;
    }

    return run_tests(
        %P,

        tests => \@tests,
    );
} # }}}

sub _run_test { # {{{
    my ( $t ) = @_;

    # Drop any remainign connection.
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

#    use Data::Dumper; warn Dumper \%url;

    $url->{'protocol'} = $url->{'protocol'} . '_test';

    my $request = SLight::Core::Request->new();

    my $result = $request->main(
        session_id => SLight::Core::Session::session_id(),
        url        => $url,
        options    => ( $t->{'cgi'} or {} ),
    );

    return $result;
} # }}}

# vim: fdm=marker
1;
