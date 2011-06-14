package SLight::Protocol::JSON;
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
use base q{SLight::Protocol};

use SLight::Core::Config;

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use File::Slurp qw( read_file );
use Params::Validate qw( :all );
# }}}

sub respond { # {{{
    my ( $self, %P ) = @_;

#    use Data::Dumper; warn Dumper \%P;

    $self->S_begin_response(%P);

    my $output_object = $self->{'output_factory'}->make(
        output => $self->_output_type(),
    );

    # Process on-page objects - start with main object.
    my $response = $self->S_process_object(
        $P{'page'}->{'objects'}->{ $P{'page'}->{'main_object'} },
        $P{'url'}->{'action'},
        $P{'url'}->{'step'},
        1,
    );

    $output_object->set_meta($response->{'meta'});

    $output_object->queue_object_data(
        $P{'page'}->{'main_object'},
        $response->{'data'},
    );

    $output_object->serialize_queued_data(
        template     => $P{'page'}->{'template'},
        object_order => $P{'page'}->{'object_order'},
    );

    $self->S_end_response();

    return $self->S_response_CONTENT(
        $output_object->return_response(),
    );
} # }}}

sub _output_type { # {{{
    return 'JSON';
} # }}}

# vim: fdm=marker
1;

