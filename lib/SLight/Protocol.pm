package SLight::Protocol;
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

my $VERSION = '0.0.3';

use SLight::AddonFactory;
use SLight::OutputFactory;
use SLight::HandlerFactory;
use SLight::DataToken qw( mk_Container_token mk_Label_token );
use SLight::Core::L10N qw( TR TF );

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

        page    => undef,
        url     => undef,
        options => undef,
        user    => undef,
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
    my ( $self, $object, $action, $step, $is_main_object ) = @_;

#    $self->D_Dump($object, $action);

    my ($pkg, $handler) = ( $object->{'class'} =~ m{^(.+?)::(.+?)$}s );

    my $handler_object = $self->{'handler_factory'}->make(pkg => $pkg, handler => $handler, action => $action );

    # FIXME! eval it, or something...

    my $result = $handler_object->handle(
        page     => $self->{'page'},
        url      => $self->{'url'},
        user     => $self->{'user'},
        options  => $self->{'options'},
        step     => $step,
        oid      => $object->{'oid'},
        metadata => $object->{'metadata'},

        is_main_object => $is_main_object
    );

    # Fixme! actually check, if this is a derivative from SLight::DataStructure (!)

    if ($result) {
#        use Data::Dumper; warn Dumper $result;

        if ($result->{'redirect'}) {
            return {
                redirect_href => $result->{'redirect'}
            };
        }
        
        if ($result->{'upload'}) {
            return {
                upload => $result->{'upload'}
            };
        }

        if ($result->{'replace_with_object'}) {
            return {
                replace_with_object => $result->{'replace_with_object'}
            };
        }
        
        assert_defined($result->{'class'}, 'Class is defined in result');
        assert_defined($result->{'data'},  'Data is defined in result');

        return {
            data => mk_Container_token(
                # TODO: add 'id' property to it, so every object has unique ID!
                class   => 'SLight_Object O-' . $result->{'class'},
                content => $result->{'data'}
            ),
            meta => $result->{'meta'}
        };
    }

    return;
} # }}}

sub S_process_addon { # {{{
    my ( $self, $class, $metadata ) = @_;
    
#    use Data::Dumper; warn "addon meta: " . Dumper $metadata;
#    use Data::Dumper; warn "page: " . Dumper $self->{'page'};
    
    my ($pkg, $addon) = ( $class =~ m{^(.+?)::(.+?)$}s );

    my $addon_object = eval {
        $self->{'addon_factory'}->make(pkg => $pkg, addon => $addon);
    };
    if ($EVAL_ERROR or not $addon_object) {
        printf STDERR "%s plugin failed to compile.\n", $pkg .q{.}. $addon;
        print STDERR $EVAL_ERROR;

        return mk_Label_token(
            class => 'SLight_Error',
            text  => TF("%s plugin failed to compile.", undef, $pkg .q{.}. $addon),
        );
    }

    my $data = eval {
        $addon_object->process(
            page_id => ( $self->{'page'}->{'page_id'} or 0 ),
            url     => $self->{'url'},
            user    => $self->{'user'},
            meta    => ( $metadata or {} ),
        );
    };
    if ($EVAL_ERROR) {
        printf STDERR "%s plugin failed to run.\n", $pkg .q{.}. $addon;
        print STDERR $EVAL_ERROR;

        return mk_Label_token(
            class => 'SLight_Error',
            text  => TF("%s plugin failed to run.", undef, $pkg .q{.}. $addon),
        );
    }

#    use Data::Dumper; warn "addon result: " . Dumper $data;

    return $data;
} # }}}

# Purpose:
#   Indicate, that response generation has started.
sub S_begin_response { # {{{
    my ( $self, %P ) = @_;

    assert_defined($P{'user'}, 'User defined');

    assert_defined($P{'url'},  'URL defined');

    assert_defined($P{'options'},  'Options defined');

    assert_defined($P{'page'}, 'Page defined');

    assert_defined($P{'page'}->{'template'}, 'Template (in page) defined');

    assert_defined($P{'page'}->{'objects'},      'Objects (in page) defined');
    assert_defined($P{'page'}->{'object_order'}, 'Object order (in page) defined');
    assert_defined($P{'page'}->{'main_object'},  'Main object (in page) defined');

    $self->{'user'}    = $P{'user'};
    $self->{'url'}     = $P{'url'};
    $self->{'page'}    = $P{'page'};
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

