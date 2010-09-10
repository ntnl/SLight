package SLight::Protocol;
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
use base q{SLight::BaseClass};

use SLight::OutputFactory;

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub new { # {{{
    my $class = shift;
    my %P = validate(
        @_,
        {
        }
    );

    # Prototype of the object:
    my $self = {
        output_factory  => undef,
        handler_factory => undef,
        addon_factory   => undef,

        url     => undef,
        options => undef,
        user    => {},
    };

    bless $self, $class;

    $self->{'output_factory'}  = SLight::OutputFactory->new();
    $self->{'handler_factory'} = SLight::HandlerFactory->new();
    $self->{'addon_factory'}   = SLight::AddonFactory->new();

    return $self;
} # }}}

# Super (S) methods - to be called by child classes (only).

# Purpose:
#   Load and run (Object)Handler, as described in the given object hash.
sub S_process_object { # {{{
    my ( $self, $object, $action, $step ) = @_;

#    $self->D_Dump($object, $action);

    my ($pkg, $handler) = ( $object->{'class'} =~ m{^(.+?)::(.+?)$}s );

    my $handler_object = $self->{'handler_factory'}->make(pkg => $pkg, handler => $handler, action => $action );

    # FIXME! eval it, or something...

    my $result = $handler_object->handle(
        url      => $self->{'url'},
        options  => $self->{'options'},
        step     => $step,
        oid      => $object->{'oid'},
        metadata => $object->{'metadata'}
    );

    # Fixme! actually check, if this is a derivative from SLight::DataStructure (!)

    if ($result->{'data'}->isa('SLight::DataStructure::Redirect')) {
        my $data = $result->{'data'}->get_data();

        return {
            redirect_href => $data->{'data'}->{'href'}
        };
    }

    $result->{'data'} = $result->{'data'}->get_data();

    return $result;
} # }}}

sub S_process_addon { # {{{
    my ( $self, $addon, $metadata ) = @_;
    
#    use Data::Dumper; warn "addon meta: " . Dumper $metadata;

    my $addon_object = $self->{'addon_factory'}->make(addon => $addon);

    my $data = $addon_object->process(
        url  => $self->{'url'},
        user => $self->{'user'},
        meta => $metadata,
    );

    return $data;
} # }}}

# Purpose:
#   Indicate, that response generation has started.
sub S_begin_response { # {{{
    my ( $self, %P ) = @_;

    assert_defined($P{'url'},  'URL defined');

    assert_defined($P{'options'},  'Options defined');

    assert_defined($P{'page'}, 'Page defined');

    assert_defined($P{'page'}->{'template'}, 'Template (in page) defined');

    assert_defined($P{'page'}->{'objects'},      'Objects (in page) defined');
    assert_defined($P{'page'}->{'object_order'}, 'Object order (in page) defined');
    assert_defined($P{'page'}->{'main_object'},  'Main object (in page) defined');

    $self->{'url'}     = $P{'url'};
    $self->{'options'} = $P{'options'};

#    $self->D_Dump($P{'url'});
#    $self->D_Dump($P{'options'});

    return;
} # }}}

# Purpose:
#   Indicate, that response generation has been prematurely generated - but it was not due to an error.
#   For example - this routine will be used when main object handler decides to return a redirection.
sub S_abort_response { # {{{

    return;
} # }}}

# Purpose:
#   Indicate, that response generation has finished.
sub S_end_response { # {{{

    return;
} # }}}

sub S_response_CONTENT { # {{{
    my ( $self, $content, $mime ) = @_;

    return {
        response => 'CONTENT',

        content   => $content,
        mime_type => $mime,
    };
} # }}}

sub S_response_REDIRECT { # {{{
    my ( $self, $href ) = @_;

    return {
        response => 'REDIRECT',
        location => $href,
    };
} # }}}


# vim: fdm=marker
1;

