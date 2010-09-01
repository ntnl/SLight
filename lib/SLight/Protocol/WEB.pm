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

    $self->_begin_response(%P);

    my $output_object = $self->{'output_factory'}->make(
        output => 'HTML', # Hard-coded for now, FIXME later.
    );

# Move to SLight::Output::HTML
#    my $template_file = SLight::Core::Config::get_option('site_root') . q{/html/} . $P{'page'}->{'template'} . q{.html};
#
#    my $template = read_file($template_file);

    # Process on-page objects - start with main object.
    my $response = $self->S_process_object($P{'page'}->{'objects'}->{ $P{'page'}->{'main_object'} });

    # Process aux objects now...
    foreach my $object_key (@{ $P{'page'}->{'object_order'} }) {
        if ($object_key eq $P{'page'}->{'main_object'}) {
            # Skip main object, it has already been processed.
            next;
        }

        my $response = $self->S_process_object($P{'page'}->{'objects'}->{ $object_key });

        $output_object->queue_object_data($object_key, $response);
    }

    $output_object->serialize_queued_data(
        object_order => $P{'page'}->{'object_order'},
    );

    $self->S_end_response();

    return $self->S_response_CONTENT(
        $output_object->return_response(),
# The above should return:
#       $template
#        q{text/html; character-set: utf-8}
    );
} # }}}

# vim: fdm=marker
1;
