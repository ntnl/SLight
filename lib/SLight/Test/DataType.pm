package SLight::Test::DataType;
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

# Test framework for DataType types.
use strict; use warnings; # {{{

use SLight::DataType;

use Carp::Assert::More qw( assert_defined );
use Params::Validate qw( :all );
use Test::More;
use Test::Exception;
use YAML::Syck qw( Dump );
# }}}

# Test the 'validate_data', 'encode_data' and 'decode_data' subroutines.
sub run_tests { # {{{
    my %P = validate(
        @_,
        {
            validate_tests => { type=>ARRAYREF },
            encode_tests   => { type=>ARRAYREF },
            decode_tests   => { type=>ARRAYREF },
            type           => { type=>SCALAR },
        }
    );

    plan tests => 
        + 1
        + ( scalar @{ $P{'validate_tests'} } )
        + ( scalar @{ $P{'encode_tests'} } )
        + ( scalar @{ $P{'decode_tests'} } )
    ;

    my $signature = SLight::DataType::signature(
        type => $P{'type'},
    );

    is (ref $signature, 'HASH', "Signature returned as hash");

    foreach my $t (@{ $P{'validate_tests'} }) {
        assert_defined($t->{'name'}, 'Test name (validate) is defined');

        my $result = SLight::DataType::validate_data(
            type   => $P{'type'},
            value  => $t->{'value'},
            format => ( $t->{'format'} or q{} ),
        );

        is($result, $t->{'expect'}, 'Validate: '. $t->{'name'});
    }
    foreach my $t (@{ $P{'encode_tests'} }) {
        assert_defined($t->{'name'}, 'Test name (encode) is defined');

        my $result = SLight::DataType::encode_data(
            type   => $P{'type'},
            value  => $t->{'value'},
            format => ( $t->{'format'} or q{} ),
        );

        is_deeply($result, $t->{'expect'}, 'Encode: '. $t->{'name'});
        
#        use Data::Dumper; warn "Result / expect: ". Dumper $result, $t->{'expect'};
    }
    foreach my $t (@{ $P{'decode_tests'} }) {
        assert_defined($t->{'name'}, 'Test name (decode) is defined');

        if ($t->{'value_yaml'}) {
            $t->{'value'} = Dump( delete $t->{'value_yaml'} );
        }

        my $result = SLight::DataType::decode_data(
            type   => $P{'type'},
            value  => $t->{'value'},
            format => ( $t->{'format'} or q{} ),
            target => ( $t->{'target'} or q{} ),
        );

        is_deeply($result, $t->{'expect'}, 'Decode: '. $t->{'name'});
    }

    return;
} # }}}

# vim: fdm=marker
1;
