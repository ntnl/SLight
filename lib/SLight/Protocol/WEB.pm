package SLight::Protocol::WEB;
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

    if (not $response) {
        # Module does not returned anything, ignore it then, maybe there's nothing to tell.
        return q{};
    }

    if ($response->{'redirect_href'}) {
        return $self->S_response_REDIRECT(
            $response->{'redirect_href'},
        );
    }

    if ($response->{'upload'}) {
        return $self->S_response_CONTENT(
            $response->{'upload'}->{'data'},
            $response->{'upload'}->{'mime'}
        );
    }

    if ($response->{'replace_with_object'}) {
        # Internal redirect :) Cool :)
        $response = $self->S_process_object(
            $response->{'replace_with_object'},
            $P{'url'}->{'action'},
            $P{'url'}->{'step'},
            1,
        );

        if ($response->{'redirect_href'}) {
            return $self->S_response_REDIRECT(
                $response->{'redirect_href'},
            );
        }
        # Yes... as soon as it proves to be working - REFACTOR! Messy! FIXME!
    }

#    use Data::Dumper; warn Dumper $response;

    # Every page should have some kind of a title...
    if (not $response->{'meta'}->{'title'}) {
        if ($P{'page'}->{'title'}) {
            $response->{'meta'}->{'title'} = $P{'page'}->{'title'};
        }
        else {
            $response->{'meta'}->{'title'} = SLight::Core::Config::get_option('name');
        }
    }

    $output_object->prepare($P{'page'}->{'template'});

    $output_object->set_meta($response->{'meta'});

    $output_object->queue_object_data(
        $P{'page'}->{'main_object'},
        $response->{'data'},
    );

    $response->{'meta'}->{'path_bar'} = [
        @{ ( $P{'page'}->{'breadcrumb_path'} or [] ) },
        @{ ( $response->{'meta'}->{'path_bar'} or [] ) },
    ];

    # Process aux objects now...
    foreach my $object_key (@{ $P{'page'}->{'object_order'} }) {
        if ($object_key eq $P{'page'}->{'main_object'}) {
            # Skip main object, it has already been processed.
            next;
        }

#        $self->D_Dump('P', \%P);

        my $aux_response = $self->S_process_object(
            $P{'page'}->{'objects'}->{ $object_key },
            'View', # <-- aux objects always run in VIEW!
            'view', # <-- aux objects always run in VIEW!
            0,
        );
        $output_object->queue_object_data(
            $object_key,
            $aux_response->{'data'}
        );
    }

    # Ask output object, about which addons are there...
    my @addons = $output_object->list_addons();

    foreach my $addon (@addons) {
        my $addon_data = $self->S_process_addon(
            $addon,
            $response->{'meta'}
        );

        if ($addon_data) {
            $output_object->queue_addon_data( $addon, $addon_data );
        }
    }

    $output_object->serialize_queued_data(
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
