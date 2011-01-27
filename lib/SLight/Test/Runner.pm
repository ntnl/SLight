package SLight::Test::Runner;
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
use base 'Exporter';
our @EXPORT_OK = qw(
    run_tests
);
our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);

use Carp::Assert::More qw( assert_defined );
use Params::Validate qw( :all );
use Test::FileReferenced;
use Test::More;
# }}}

# Generif routine that can run a number of callback-based tests,
# get their output, compare it with some reference YAML file and display a report.
# Each test is a hash ref with:
# {
#   name     : test name
#   callback : function, that will be tested/will do test, to call
#   args     : array ref, with arguments for the test function
#   output   : expected output, optional.
#   expect   : scalar | array | hash | arrayref | hashref, optional, default: scalar
# }
#
# Parameters:
#   tests : table with tests.
#
#   call_before : optional : callback that will be run before a test is run, unless overwritten in test.
#   call_result : optional : callback that will be run on test results, before checking, unless overwritten in test.
#   call_after  : optional : callback that will be run after a test is run, unless overwritten in test.
sub run_tests { # {{{
    my %P = validate(
        @_,
        {
            tests => { type=>ARRAYREF },

            call_before => { type=>CODEREF, optional=>1 },
            call_format => { type=>CODEREF, optional=>1 },
            call_result => { type=>CODEREF, optional=>1 },
        }
    );

    # Plan our tests.
    plan tests => scalar @{ $P{'tests'} };

    # Wrappers are responsible for calling the main test callback in a proper way.
    my %wrappers = (
        'undef'    => sub { my $call = shift; my $r = &{ $call }(@_); return ($r, (not defined $r)); },
        'scalar'   => sub { my $call = shift; my $r = &{ $call }(@_); return ($r, (not ref $r)); },
        'array'    => sub { my $call = shift; my @r = &{ $call }(@_); return (\@r, 1); },
        'hash'     => sub { my $call = shift; my %r = &{ $call }(@_); return (\%r, ( (scalar keys %r) % 2 == 0) ); },
        'arrayref' => sub { my $call = shift; my $r = &{ $call }(@_); return ($r, (ref $r eq 'ARRAY')); },
        'hashref'  => sub { my $call = shift; my $r = &{ $call }(@_); return ($r, (ref $r eq 'HASH')); },
    );

    # Start testing...
    my $failed = 0;
    foreach my $t (@{ $P{'tests'} }) {
        # Check for callback that should be run before the test.
        if ($t->{'call_before'}) {
            &{ $t->{'call_before'} }($t);
        }
        elsif ($P{'call_before'}) {
            &{ $P{'call_before'} }($t);
        }

        if (not $t->{'expect'}) {
            $t->{'expect'} = 'scalar';
        }
        my $wrapper = $wrappers{ $t->{'expect'} };
        my ($test_result, $type_ok) = &{ $wrapper }( $t->{'callback'}, @{ $t->{'args'} } );
        
        if ($type_ok) {
            # Check for callback that should be run on test results.
            if ($t->{'call_result'}) {
                &{ $t->{'call_result'} }($t, $test_result);
            }
            elsif ($P{'call_result'}) {
                &{ $P{'call_result'} }($t, $test_result);
            }

            is_referenced_ok($test_result, $t->{'name'});
        }
        else {
            fail($t->{'name'});
            diag('Test callback returned unexpected type of data.');

            use Data::Dumper;

            note(Dumper $test_result);

            $failed++;
        }

        # Check for callback that should be run after the test.
        if ($t->{'call_after'}) {
            &{ $t->{'call_after'} }($t);
        }
        elsif ($P{'call_after'}) {
            &{ $P{'call_after'} }($t);
        }
    }

    return $failed;
} # }}}

# vim: fdm=marker
1;

