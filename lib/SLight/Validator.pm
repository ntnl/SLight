package SLight::Validator;
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
    validate_input
);
our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);

use SLight::Core::L10N qw( TR TF );

use Carp::Assert::More qw( assert_defined );
# }}}

# This module handles framework-related tasks.
# Actual data validation is implemented by Validator/*.pm modules.
# Those additional modules are loaded on-demand, when needed.

my %validators = (
    'ASCII'   => { module=>'Simple.pm', function=>\&SLight::Validator::Simple::v_ASCII },
    'String'  => { module=>'Simple.pm', function=>\&SLight::Validator::Simple::v_String },
    'Text'    => { module=>'Simple.pm', function=>\&SLight::Validator::Simple::v_Text },
    'Integer' => { module=>'Simple.pm', function=>\&SLight::Validator::Simple::v_Integer, base=>[qw{ STRING }] },

    'Email' => { module=>'Net.pm', function=>\&SLight::Validator::Net::v_Email, base => [qw{ STRING }] },
    'URL'   => { module=>'Net.pm', function=>\&SLight::Validator::Net::v_Url,   base => [qw{ STRING }] },
    
    'Login'    => { module=>'User.pm', function=>\&SLight::Validator::User::v_Login,    base => [qw{ STRING }] },
    'NewLogin' => { module=>'User.pm', function=>\&SLight::Validator::User::v_NewLogin, base => [qw{ STRING }] },
    'Password' => { module=>'User.pm', function=>\&SLight::Validator::User::v_Password, base => [qw{ STRING }] },
    
    'FileName' => { module=>'Disk.pm', function=>\&SLight::Validator::Disk::v_FileName, base => [qw{ STRING }] },

    'ISO_Date'     => { module=>'Time.pm', function=>\&SLight::Validator::Time::v_ISO_Date,     base => [qw{ STRING }] },
    'ISO_Time'     => { module=>'Time.pm', function=>\&SLight::Validator::Time::v_ISO_Time,     base => [qw{ STRING }] },
    'ISO_DateTime' => { module=>'Time.pm', function=>\&SLight::Validator::Time::v_ISO_DateTime, base => [qw{ STRING }] },

    # This will pass anything.
    # Use this validator, if - for some reason - You HAVE to enter something.
    'Any' => { module=>'Simple.pm', function=>sub { return; } },
);

# Validate input (given in first hash ref), according to recipy (given in second another hashref)
# Returns undef if no problems ware found.
# Meta hash should contain hashes, like: {
#   item => {
#       optional => BOOL,
#           # Ignore the fact, that the value is not defined
#
#       type => STRING,
#           # Code from %validators hash
#
#       max_length => INT,
#           # Max length, in characters, that this field can accept.
#
#       extras => {},
#           # Extra parameters, required by specific validation routine.
#   }
# }
# 
# By default, if a key is in metadata, its presence will be checked. If it is missing,
# error will be returned.
#
# Parameters:
#   data hash (data to validate)
#   meta hash (data descrpittion, metadata)
sub validate_input { # {{{
    my ( $data_hash, $meta_hash ) = @_;

    my %errors;

    foreach my $data_key (keys %{ $meta_hash }) {
        my $meta = $meta_hash->{$data_key};

        # Check if data is present.
        if (not defined $data_hash->{$data_key} or $data_hash->{$data_key} eq q{}) {
            # Data is not present...
            if ($meta->{'optional'}) {
                # But is is optional, so everything is OK :)
                next;
            }

            # Missing data triggers a warning.
            $errors{$data_key} = TR('This field may not be empty.');

            # Skip to next field. We already know, that this one is invalid :(
            next;
        }

        # Is there any limit on the field's length?
        if ($meta->{'max_length'} and length $data_hash->{$data_key} > $meta->{'max_length'}) {
            $errors{$data_key} = TF('Maximum number of chacters (%d) has been exceeded', undef, $meta->{'max_length'});
            next;
        }

        assert_defined($validators{ $meta->{'type'} }, q{Validation type: '}. $meta->{'type'} .q{' supported});

        # Check if data is valid.
        my $require_module = q{SLight/Validator/}. $validators{ $meta->{'type'} }->{'module'};

        # Todo: some eval would be nice :)
        require $require_module;

        my $result = &{ $validators{ $meta->{'type'} }->{'function'} }(
            $data_hash->{$data_key},
            ( $meta->{'extras'} or {} )
        );

        if ($result) {
            $errors{$data_key} = $result;
        }
    }

    if (scalar keys %errors) {
        return \%errors;
    }

    return;
} # }}}

# vim: fdm=marker
1;
