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
use YAML::Syck qw( Dump Load );
# }}}

sub run_handler_tests { # {{{
    my %P = validate(
        @_,
        {
            tests => { type=>ARRAYREF },

            call_before => { type=>CODEREF, optional=>1 },
            call_format => { type=>CODEREF, optional=>1 },
            call_result => { type=>CODEREF, optional=>1 },

            strip_dates => { type=>SCALAR, optional=>1 },
        }
    );

    my $strip_dates = ( delete $P{'strip_dates'} or 0 );

    my @tests;
    foreach my $t (@{ $P{'tests'} }) {
        my %runner_test = (
            name     => $t->{'name'},
            expect   => ( $t->{'expect'} or 'hashref' ),
            callback => \&_run_test,
            args     => [
                $t,
                {
                    strip_dates => $strip_dates,
                }
            ],
        );

        foreach my $cb (qw( call_after call_results call_before )) {
            if ($t->{$cb}) {
                $runner_test{$cb} = $t->{$cb};
            }
        }

        if ($t->{'sql_query'}) {
            $runner_test{'expect'}   = 'arrayref';
            $runner_test{'callback'} = \&_run_query_test;
            $runner_test{'args'}     = [ $t->{'sql_query'} ]; 
        }
        elsif ($t->{'callback'}) {
            $runner_test{'callback'} = $t->{'callback'};
            $runner_test{'args'}     = ( $t->{'args'} or [] ); 
        }

        foreach my $cb_field (qw( call_before call_format call_result )) {
            $runner_test{$cb_field} = $t->{$cb_field};
        }

        push @tests, \%runner_test;
    }

    return run_tests(
        %P,

        tests => \@tests,
    );
} # }}}

sub _run_test { # {{{
    my ( $t, $opts ) = @_;

    # Drop any remaining connection.
    # Request has to be able to re-connect by itself.
    SLight::Core::DB::disconnect();

    if ($t->{'session'}) {
        SLight::Core::Session::drop();

        SLight::Core::Session::start();

        foreach my $part (keys %{ $t->{'session'} }) {
            SLight::Core::Session::part_set($part, $t->{'session'}->{$part});
        }
        
        SLight::Core::Session::save();
    }

    assert_defined($t->{'url'});

    my $url = SLight::Core::URL::parse_url($t->{'url'});

#    use Data::Dumper; warn Dumper \%url;

    $url->{'protocol'} = $url->{'protocol'} . '_test';

    my $request = SLight::Core::Request->new();

    my $result = $request->main(
        session_id => SLight::Core::Session::session_id(),
        url        => $url,
        options    => ( $t->{'cgi'} or {} ),
    );

    if ($opts->{'strip_dates'}) {
        $result = _strip_dates($result);
    }

    return $result;
} # }}}

sub _strip_dates { # {{{
    my ( $results ) = @_;

    # Fixme: this is a bit lame... but hey! It works, and I implemented it in 15 sec!
    my $crap = Dump($results);
    $crap =~ s{\d\d\d\d\-\d\d\-\d\d \d\d\:\d\d\:\d\d}{##DATE(yyyy-mm-dd hh:mm:ss) IS SANE##}sgi;

    return Load($crap);
} # }}}

sub _run_query_test { # {{{
    my ( $query ) = @_;

    my @results;

    SLight::Core::DB::check();

    my $sth = SLight::Core::DB::run_query(
        query => $query,
    );
    while (my $row = $sth->fetchrow_hashref()) {
        push @results, $row;
    }

    return \@results;
} # }}}

# vim: fdm=marker
1;
