package SLight::Protocol::WEB;
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
use base q{SLight::Protocol};

use SLight::Core::Config;

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use File::Slurp qw( read_file );
use Params::Validate qw( :all );
# }}}

sub respond { # {{{
    my ( $self, %P ) = @_;

    $self->S_begin_response(%P);

    my $output_object = $self->{'output_factory'}->make(
        output => $self->_output_type(),
    );

    my $main_meta_data;

    # Process on-page objects - start with main object.
    my $response = $self->S_process_object(
        $P{'page'}->{'objects'}->{ $P{'page'}->{'main_object'} },
        $P{'url'}->{'action'},
        $P{'url'}->{'step'}
    );
    $output_object->queue_object_data(
        $P{'page'}->{'main_object'},
        $response->{'data'},
    );

    use Data::Dumper; warn Dumper $response;

    # Use 'meta' to prepare plugins...
    # $output_object->add_metadata($response->{'meta'});

    # Process aux objects now...
    foreach my $object_key (@{ $P{'page'}->{'object_order'} }) {
        if ($object_key eq $P{'page'}->{'main_object'}) {
            # Skip main object, it has already been processed.
            next;
        }

#        $self->D_Dump('P', \%P);

        my $aux_response = $self->S_process_object(
            $P{'page'}->{'objects'}->{ $object_key },
            $P{'url'}->{'action'},
            'view' # <-- aux objects always run in VIEW!
        );
        $output_object->queue_object_data(
            $object_key,
            $aux_response->{'data'}
        );
    }

    # Ask output object, about which addons are there...
    my @addons = $output_object->list_addons();

    foreach my $addon (@addons) {
        warn "Adding $addon Addon!";

        $output_object->queue_addon_data(
            $addon,
            $self->S_process_addon(
                $addon,
                $response->{'meta'}
            ),
        );
    }

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
    return 'HTML';
} # }}}

# vim: fdm=marker
1;
