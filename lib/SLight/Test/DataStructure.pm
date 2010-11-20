package SLight::Test::DataStructure;
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
    run_datastructure_tests
);
our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);

use SLight::Core::Request;
use SLight::Core::URL;
use SLight::Test::Runner qw( run_tests );

use Carp::Assert::More qw( assert_defined );
use Params::Validate qw( :all );
use YAML::Syck qw( Dump Load );
# }}}

=head2 USAGE

my %cases = (
    "simple stuff" => {
        params => { # Parameters for DataStructure instance
            one => '1',
            two => '2'
        },
        tests => [ # Work done on the DataStructure
            {
                name   => "test 1",
                method => 'add_Stuff',     # DataStructure's method to use...
                args   => { foo => 'bar' } # ...and it's parameters.
            }
            {
                name => "Test 2",
                # ...
            }
        ], # When all tests are run, the get_data-based test is fired too
    },
    "other stuff" => {
        # ...
    }
);

=cut

sub run_datastructure_tests { # {{{
    my %P = validate(
        @_,
        {
            tests => { type=>HASHREF },

            call_before => { type=>CODEREF, optional=>1 },
            call_format => { type=>CODEREF, optional=>1 },
            call_result => { type=>CODEREF, optional=>1 },

            structure => { type => SCALAR },
        }
    );

    my $structure_class = q{SLight::DataStructure::} . delete $P{'structure'};

    my $class_filename = $structure_class . q{.pm};
    $class_filename =~ s{::}{/}sgi;

    require $class_filename;

    my @tests;
    foreach my $case_name (keys %{ $P{'tests'} }) {
        my $case = $P{'tests'}->{$case_name};

        my $structure = $structure_class->new(
            %{ $case->{'params'} }
        );

        foreach my $t (@{ $case->{'tests'} }) {
            assert_defined($t->{'method'}, q{Method name is defined});
            assert_defined($t->{'args'},   q{Method arguments is defined});

            my %runner_test = (
                name     => $case_name . q{ - } . $t->{'name'},
                expect   => ( $t->{'expect'} or 'hashref' ),
                callback => \&_run_test,
                args     => [
                    $structure,
                    $t->{'method'},
                    $t->{'args'},
                ]
            );

            foreach my $cb_field (qw( call_before call_format call_result )) {
                $runner_test{$cb_field} = $t->{$cb_field};
            }

            push @tests, \%runner_test;
        }

        push @tests, {
            name     => $case_name,
            expect   => 'hashref',
            callback => \&_run_final_test,
            args     => [
                $structure,
            ]
        };
    }

    return run_tests(
        %P,

        tests => \@tests,
    );
} # }}}

sub _run_test { # {{{
    my ( $structure, $method, $args ) = @_;
    
    return $structure->$method( @{ $args } );
} # }}}

sub _run_final_test { # {{{
    my ( $structure ) = @_;

    return $structure->get_data();
} # }}}

# vim: fdm=marker
1;
