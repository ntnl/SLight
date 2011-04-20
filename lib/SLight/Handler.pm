package SLight::Handler;
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

use SLight::HandlerUtils::Toolbox;

use Carp;
use Carp::Assert::More qw( assert_defined assert_hashref assert_listref );
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
        class => undef,
        data  => [],
        meta  => {},

        redirect => undef,
        
        upload => undef,

        read_only => 0,

        url  => undef,

        user => {},
    };

    bless $self, $class;

    return $self;
} # }}}

sub handle { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            step    => { type=>SCALAR },
            page    => { type=>HASHREF },
            url     => { type=>HASHREF },
            user    => { type=>HASHREF },
            options => { type=>HASHREF },
            
            oid      => { type=>SCALAR | UNDEF },
            metadata => { type=>HASHREF | UNDEF },
            
            is_main_object => { type=>SCALAR },
        }
    );
    
    $self->{'page'}    = $P{'page'};
    $self->{'url'}     = $P{'url'};
    $self->{'user'}    = $P{'user'};
    $self->{'options'} = $P{'options'};

    $self->{'is_main_object'} = $P{'is_main_object'};

#    use Data::Dumper; warn Dumper \%P;

    my $method_name = 'handle_view';
    if ($P{'step'} ne 'view') {
        $method_name = q{handle_} . $P{'step'};
    }

#    warn "Calling: $method_name";

    $self->$method_name($P{'oid'}, $P{'metadata'});

#    use Data::Dumper; warn 'Final data/metadata from Handler object: '. Dumper {
#        data => $self->{'data'},
#        meta => $self->{'meta'},
#    };

    if ($self->{'redirect'}) {
        return {
            redirect => $self->{'redirect'}
        };
    }

    if ($self->{'upload'}) {
        return {
            upload => $self->{'upload'}
        };
    }

    if ($self->{'replace_with_object'}) {
        return {
            replace_with_object => $self->{'replace_with_object'}
        };
    }

    return {
        class => $self->{'class'},
        data  => $self->{'data'},
        meta  => $self->{'meta'},
    };
} # }}}

sub is_main_object { # {{{
    my ( $self ) = @_;

    return $self->{'is_main_object'};
} # }}}

# Purpose:
#   Define object's class.
sub set_class { # {{{
    my ( $self, $class ) = @_;

    return $self->{'class'} = $class;
} # }}}

# Purpose:
#   Append some data to the Handler's output.
#   Data can be an DataStructure object or DataToken structure.
sub push_data { # {{{
    my ( $self, $data ) = @_;

    assert_defined($data, 'Data must be defined');

    # FIXME: make sure redirect was not set! If so, something is br0ken!
    
    if (ref $data eq 'HASH') {
        push @{ $self->{'data'} }, $data;
    }
    elsif (eval { $data->isa('SLight::DataStructure'); }) { # If it's not object, it will not crash.
        push @{ $self->{'data'} }, $data->get_data();
    }

    return;
} # }}}

# Purpose:
#   Utility method to save typing and keep the code clean.
#
#   Add Toolbox to the object's output (so, not as part of the page, but a part of the object).
sub push_toolbox { # {{{
    my ( $self, %toolbox ) = @_;

    if ($self->{'user'}->{'id'} and not $toolbox{'user_id'}) {
        $toolbox{'user_id'} = $self->{'user'}->{'id'};
    }

    return $self->push_data(
        $self->make_toolbox(%toolbox)
    );
} # }}}

sub redirect { # {{{
    my ( $self, $redirect ) = @_;

    # FIXME: make sure no upload/data was set! If so, something is br0ken!
    
    $self->{'redirect'} = $redirect;

    return;
} # }}}

sub upload { # {{{
    my ( $self, $data, $mime ) = @_;

    assert_defined($data, "Data is defined");
    assert_defined($mime, "Mime type is defined");

    # FIXME: make sure no redirect/data was set! If so, something is br0ken!
    
    $self->{'upload'} = {
        data => $data,
        mime => $mime,
    };

    return;
} # }}}

sub replace_with_object { # {{{
    my ( $self, %P ) = @_;

    # FIXME: make sure that the %P contains the object data (class, oid, metadata)
    
    $self->{'replace_with_object'} = \%P;

    return;
} # }}}

sub set_meta_field { # {{{
    my ( $self, $field, $value ) = @_;
    
    my %field_regex = (
        title        => qr{..+}s,
        handle_time  => qr{^[0-9]([0-9\.]*[0-9])?$}s, ## no critic qw(ProhibitPunctuationVars)
        auto_refresh => qr{.+}s,
    );

    assert_defined($field_regex{$field}, "Field: '$field' not supported.");
    assert_defined(
        ( $value =~ $field_regex{$field} ),
        "Value of $field ($value) does not satisfy regex."
    );

    $self->{'meta'}->{$field} = $value;

    return $value;
} # }}}

# Purpose:
#   This method sets the page-wide 'toolbox' for the Toolbox addon.
#   This should be an ARRAY with actions that can be performed on current Handler and path.
sub set_toolbox { # {{{
    my (
        $self,
        $toolbox
    ) = @_;

    assert_listref(
        $toolbox,
        "Toolbox is an ARRAYREF"
    );

    $self->{'meta'}->{'toolbox'} = $toolbox;

    return;
} # }}}

# This method adds element to Path Bar.
# Path Bar may then be shown by PathBar Plugin.
sub add_to_path_bar { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            url   => { type=>HASHREF },
            label => { type=>SCALAR },
        }
    );

#    warn "Adding to hap bar!";

    if (not $self->{'meta'}->{'path_bar'}) {
        $self->{'meta'}->{'path_bar'} = [];
    }
    else {
        # Switch class of the most recent item to 'Parent'
        # This way it will be very easy to hook different stylle to the 'current' item (see below).
        $self->{'meta'}->{'path_bar'}->[ -1 ]->{'class'} = 'Parent';
    }

    push @{ $self->{'meta'}->{'path_bar'} }, {
        href  => $self->build_url( %{ $P{'url'} } ),
        label => $P{'label'},
        class => 'Current',
    };

    return;
} # }}}

# Add information to 'Notification' list.
# Each notification should have:
#   type : One of: CRITICAL, ERROR, WARNING, INFO, HINT
#   text : Description of the notification
sub add_notification { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            id   => { type=>SCALAR },
            type => { type=>SCALAR },
            text => { type=>SCALAR },
        }
    );

    my $id = delete $P{'id'};

    $self->{'meta'}->{'notifications'}->{$id} = \%P;

    return;
} # }}}

################################################################################
# Utility functions
################################################################################

# Purpose:
#   Build an SLight URL.
#   By default, the new URL will be based on the URL that is currently being viewed.
#   This base can then be altered in many ways.
#   Note:
#       The 'page' parameter is not set automatically! 
sub build_url { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            path_handler => { type=>SCALAR,   optional=>1 },
            path         => { type=>ARRAYREF, optional=>1 },
            add_to_path  => { type=>ARRAYREF, optional=>1 },

            step    => { type=>SCALAR,   optional=>1 },
            handler => { type=>SCALAR,   optional=>1 },
            action  => { type=>SCALAR,   optional=>1 },
            page    => { type=>SCALAR,   optional=>1 },
            options => { type=>HASHREF,  optional=>1 },
            method  => { type=>SCALAR,   optional=>1 },

            lang => { type=>SCALAR, optional=>1 },
        
            add_domain => { type=>SCALAR, optional=>1 },
        }
    );

    # Check if User has made an explicit selection of the langiage.
    # In this case, every URL generated by SLight should have this language defined.
    # This is, because User could want to send the link to someone.
    # User would probably expect, that the receiver gets the same language, as the User had.

#    use Data::Dumper; warn Dumper $self->{'url'};

    my %parts = (
        path_handler => ( $P{'path_handler'} or $self->{'url'}->{'path_handler'} ),

        action  => ( $P{'action'}  or $self->{'url'}->{'action'} ),
        step    => ( $P{'step'}    or $self->{'url'}->{'step'} ),
        path    => ( $P{'path'}    or $self->{'url'}->{'path'} or [] ),
        options => ( $P{'options'} or $self->{'url'}->{'options'} or {} ),

        page    => ( $P{'page'}    or 1 ),
        lang    => ( $P{'lang'}    or $self->{'user'}->{'lang'} or q{} ),
        
        add_domain => ( $P{'add_domain'} or 0 ),
    );

    if ($P{'add_to_path'}) {
        $parts{'path'} = [
            @{ $parts{'path'} },
            @{ $P{'add_to_path'} }
        ];
    }
    
    my $url = SLight::Core::URL::make_url(%parts);

    return $url;
} # }}}

# Redirect to the Handler's overview.
# Todo:
#   Add posibility to display some informtion (alert, etc) with link to overview.
sub redirect_to_overview { # {{{
    my $self = shift;

    my $target_url = $self->build_url(
        method  => 'GET',
        action  => 'overview',
        options => {},
        path    => q{/}
    );

    return $self->set_redirect($target_url);
} # }}}

# Purpose:
#   Build URL toolbox with given actions.
#   Action will appear only, if the User has Grant to use it.
sub make_toolbox { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            urls => { type=>ARRAYREF },

            path_handler => { type=>SCALAR, optional=>1, default=>$self->{'url'}->{'path_handler'} },
            path         => { type=>SCALAR, optional=>1, default=>$self->{'url'}->{'path'} },
            add_to_path  => { type=>ARRAYREF, optional=>1 },
            
            options  => { type=>HASHREF, optional=>1 },

            action => { type=>SCALAR, optional=>1, default=>$self->{'url'}->{'action'} },
            step   => { type=>SCALAR, optional=>1, default=>$self->{'url'}->{'step'} },
            lang   => { type=>SCALAR, optional=>1, default=>$self->{'url'}->{'lang'} },
            page   => { type=>SCALAR, optional=>1, default=>$self->{'url'}->{'page'} },

            protocol => { type=>SCALAR, optional=>1, default=>$self->{'url'}->{'protocol'} },
            
            user_id => { type=>SCALAR, optional=>1 },
        }
    );

    # Outsource work to outside function.
    return SLight::HandlerUtils::Toolbox::make_toolbox(
        %P,

        class => 'SLight_Toolbox',

#        login => $self->{'user'}->{'login'},
    );
} # }}}

# vim: fdm=marker
1;
