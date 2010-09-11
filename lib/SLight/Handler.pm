package SLight::Handler;
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
        meta => {},

        read_only => 0,

        url  => undef,
        user => {}, # Planned for Milestone 4
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
            url     => { type=>HASHREF },
            options => { type=>HASHREF },
            
            oid      => { type=>SCALAR | UNDEF },
            metadata => { type=>HASHREF | UNDEF },
        }
    );
    
    $self->{'url'}     = $P{'url'};
    $self->{'options'} = $P{'options'};

    my $method_name = 'handle_view';
    if ($P{'step'} ne 'view') {
        $method_name = q{handle_} . $P{'step'};
    }

#    warn "Calling: $method_name";

    my $data_structure = $self->$method_name($P{'oid'}, $P{'metadata'});

    return {
        data => $data_structure,
        meta => $self->{'meta'},
    };
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
#   This method sets the 'toolbox' urls for the Toolbox plugin.
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

# Purpose:
#   This method sets the 'pager' metadata used by the Pager plugin.
#   This should be a HASHREF, that describes the pager, as in this example:
#   {
#       current_page => 2,
#       pages_count  => 5,
#   }
sub set_pager { # {{{
    my (
        $self,
        $pager
    ) = @_;
    
    confess_on_false(
        (ref $pager eq 'HASH'),
        "Pager must be an HASHREF"
    );

    $self->{'meta'}->{'pager'} = $pager;

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
#   Build an CoMe URL.
#   By default, the new URL will be based on the URL that is currently being viewed.
#   This base can then be altered in many ways.
#   Note:
#       The 'page' parameter is not set automatically! 
sub build_url { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            add_to_path => { type=>SCALAR, optional=>1 },

            path_handler => { type=>SCALAR,   optional=>1 },
            step         => { type=>SCALAR,   optional=>1 },
            handler      => { type=>SCALAR,   optional=>1 },
            action       => { type=>SCALAR,   optional=>1 },
            path         => { type=>ARRAYREF, optional=>1 },
            page         => { type=>SCALAR,   optional=>1 },
            options      => { type=>HASHREF,  optional=>1 },
            method       => { type=>SCALAR,   optional=>1 },

            lang => { type=>SCALAR, optional=>1 },
        }
    );

    # Check if User has made an explicit selection of the langiage.
    # In this case, every URL generated by CoMe should have this language defined.
    # This is, because User could want to send the link to someone.
    # User would probably expect, that the receiver gets the same language, as the User had.

#    use Data::Dumper; warn Dumper $self->{'url'};

    my %parts = (
        path_handler => ( $P{'path_handler'} or $self->{'url'}->{'path_handler'} ),

        action  => ( $P{'action'}  or $self->{'url'}->{'action'} ),
        step    => ( $P{'step'}    or $self->{'url'}->{'step'} ),
        path    => ( $P{'path'}    or $self->{'url'}->{'path'} ),
        options => ( $P{'options'} or $self->{'url'}->{'options'} or {} ),

        page    => ( $P{'page'}    or 1 ),
        lang    => ( $P{'lang'}    or $self->{'user'}->{'lang'} or q{} ),
    );

    if ($P{'add_to_path'}) {
        $parts{'path'} =~ s{/*$}{/}s;
        $parts{'path'} .= $P{'add_to_path'} . q{/};
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

            path_handler => { type=>SCALAR, optional=>1 },
            path         => { type=>SCALAR, optional=>1 },

            action => { type=>SCALAR, optional=>1 },
            step   => { type=>SCALAR, optional=>1 },
            lang   => { type=>SCALAR, optional=>1 },
            page   => { type=>SCALAR, optional=>1 },

            protocol => { type=>SCALAR, optional=>1 },
        }
    );

    # Outsource work to outside function.
    return SLight::HandlerUtils::Toolbox::make_toolbox(
        %P,

        class => 'SLight_Toolbox',
        login => $self->{'user'}->{'login'},

        lang => ( $self->{'user'}->{'lang'} or q{} ),
    );
} # }}}

# vim: fdm=marker
1;
