package SLight::DataStructure::Form::Diff;
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

# Diff Form Response.
#
# An 'upgrade' to Genericform, that allows to display two columns of editable controls.
# Ideal for making 'diff'-like screens, or for other convertion/translation forms.
use strict; use warnings; # {{{
use base 'SLight::DataStructure::Form';

use SLight::DataToken qw( mk_Label_token mk_Entry_token mk_Container_token mk_TextEntry_token );

use Params::Validate qw( :all );
# }}}

sub add_Entry { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            name    => { type=>SCALAR },
            caption => { type=>SCALAR },

            name_a  => { type=>SCALAR },
            value_a   => { type=>SCALAR },
            error_a   => { type=>SCALAR | UNDEF, optional=>1 },

            name_b  => { type=>SCALAR },
            value_b   => { type=>SCALAR },
            error_b   => { type=>SCALAR | UNDEF, optional=>1 },
        }
    );

    my @content = (
        mk_Label_token(
            class => 'Name',
            text  => $P{'caption'},
        ),
        mk_Entry_token(
            class => 'ValueA',
            name  => $P{'name_a'},
            value => $P{'value_a'},
        ),
        mk_Entry_token(
            class => 'ValueB',
            name  => $P{'name_b'},
            value => $P{'value_b'},
        ),
    );
    if ($P{'error_a'}) {
        push @content, mk_Label_token(
            class => 'ErrorA',
            text  => $P{'error_a'},
        );
    }
    if ($P{'error_b'}) {
        push @content, mk_Label_token(
            class => 'ErrorB',
            text  => $P{'error_b'},
        );
    }
    
    push @{ $self->{'FormContent'} }, mk_Container_token(
        class   => $P{'name'},
        content => \@content,
    );

    return;
} # }}}

sub add_PasswordEntry { # {{{
    return;
} # }}}

sub add_TextEntry { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            name    => { type=>SCALAR },
            caption => { type=>SCALAR },

            name_a  => { type=>SCALAR },
            value_a => { type=>SCALAR },
            error_a => { type=>SCALAR | UNDEF, optional=>1 },

            name_b  => { type=>SCALAR },
            value_b => { type=>SCALAR },
            error_b => { type=>SCALAR | UNDEF, optional=>1 },
        }
    );

    my @content = (
        mk_Label_token(
            class => 'name',
            text  => $P{'caption'},
        ),
        mk_TextEntry_token(
            class => 'ValueA',
            name  => $P{'name_a'},
            value => $P{'value_a'},
        ),
        mk_TextEntry_token(
            class => 'ValueB',
            name  => $P{'name_b'},
            value => $P{'value_b'},
        ),
    );
    if ($P{'error_a'}) {
        push @content, mk_Label_token(
            class => 'ErrorA',
            text  => $P{'error_a'},
        ),
    }
    if ($P{'error_b'}) {
        push @content, mk_Label_token(
            class => 'ErrorB',
            text  => $P{'error_b'},
        ),
    }

    push @{ $self->{'FormContent'} }, mk_Container_token(
        class   => $P{'name'},
        content => \@content,
    );

    return;
} # }}}

sub add_SelectEntry { # {{{
    return;
} # }}}

sub add_FileEntry { # {{{
    return;
} # }}}

sub add_Check { # {{{
    return;
} # }}}

# vim: fdm=marker
1;
