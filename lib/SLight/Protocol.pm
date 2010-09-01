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
        output_factory => undef,
    };

    bless $self, $class;

    $self->{'output_factory'} = SLight::OutputFactory->new();

    return $self;
} # }}}

# Super (S) methods - to be called by child classes.

# Purpose:
#   Indicate, that response generation has started.
sub S_begin_response { # {{{
    my ( $self, %P ) = @_;

    assert_defined($P{'page'}, 'Page defined');
    assert_defined($P{'url'},  'URL defined');

    assert_defined($P{'page'}->{'template'}, 'Template (in page) defined');

    assert_defined($P{'page'}->{'objects'},      'Objects (in page) defined');
    assert_defined($P{'page'}->{'object_order'}, 'Object order (in page) defined');
    assert_defined($P{'page'}->{'main_object'},  'Main object (in page) defined');

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

#sub run_plugins { # {{{
#    my $self = shift;
#    my %P = validate(
#        @_,
#        {
#            output   => { type=>HASHREF },
#            options  => { type=>HASHREF },
#            url      => { type=>HASHREF },
#            user     => { type=>HASHREF },
#            lang     => { type=>SCALAR },
#        }
#    );
#
#    my %plugins_data;
#
#    foreach my $plugin (qw( ContentMenu ContentSubMenu PathBar Notification Toolbox Language Handlers Output UserPanel SysInfo Pager )) {
#        # Error in a single plugin should not take the whole subsystem down.
#        $plugins_data{$plugin} = eval {
#            my $plugin_object = $self->{'plugin_factory'}->make(
#                type => $plugin
#            );
#
#            return $plugin_object->process(
#                %P,
#            );
#        };
#
#        carp_on_true($EVAL_ERROR, "Plugin error: ". $EVAL_ERROR);
#    }
#
#    use Data::Dumper; warn "Plugin Data: ". Dumper \%plugins_data;
#
#    return \%plugins_data;
#} # }}}


# vim: fdm=marker
1;

