package SLight::DataStructure::Form;
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

# GenericForm Response.
use strict; use warnings; # {{{
use base 'SLight::DataStructure';

use Params::Validate qw( :all );
# }}}

# Initialize the GenericForm.
sub _new { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            action => { type=>SCALAR },
            hidden => { type=>HASHREF },
            submit => { type=>SCALAR },
            class  => { type=>SCALAR, optional=>1, default=>'generic' },
        }
    );

    $self->{'FormContent'} = [];

    $self->set_data(
        $self->make_Form(
            class   => $P{'class'},
            hidden  => $P{'hidden'},
            action  => $P{'action'},
            submit  => $P{'submit'},
            content => $self->{'FormContent'},
        )
    );

    return;
} # }}}

sub add_Entry { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            name    => { type=>SCALAR },
            caption => { type=>SCALAR },
            value   => { type=>SCALAR },
            error   => { type=>SCALAR | UNDEF, optional=>1 },
        }
    );
    
    my @content = (
        $self->make_Label(
            class => 'name',
            text  => $P{'caption'},
        ),
        $self->make_Entry(
            class => 'value',
            name  => $P{'name'},
            value => $P{'value'},
        ),
    );
    if ($P{'error'}) {
        push @content, $self->make_Label(
            class => 'Error',
            text  => $P{'error'},
        ),
    }
    
    push @{ $self->{'FormContent'} }, $self->make_Container(
        class   => $P{'name'},
        content => \@content,
    );

    return;
} # }}}

sub add_PasswordEntry { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            name    => { type=>SCALAR },
            caption => { type=>SCALAR },
            value   => { type=>SCALAR },
            error   => { type=>SCALAR | UNDEF, optional=>1 },
        }
    );
    
    my @content = (
        $self->make_Label(
            class => 'name',
            text  => $P{'caption'},
        ),
        $self->make_PasswordEntry(
            class => 'value',
            name  => $P{'name'},
            value => $P{'value'},
        )
    );
    if ($P{'error'}) {
        push @content, $self->make_Label(
            class => 'Error',
            text  => $P{'error'},
        ),
    }

    push @{ $self->{'FormContent'} }, $self->make_Container(
        class   => $P{'name'},
        content => \@content,
    );

    return;
} # }}}

sub add_TextEntry { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            name    => { type=>SCALAR },
            caption => { type=>SCALAR },
            value   => { type=>SCALAR },
            error   => { type=>SCALAR | UNDEF, optional=>1 },
        }
    );

    my @content = (
        $self->make_Label(
            class => 'name',
            text  => $P{'caption'},
        ),
        $self->make_TextEntry(
            class => 'value',
            name  => $P{'name'},
            value => $P{'value'},
        ),
    );
    if ($P{'error'}) {
        push @content, $self->make_Label(
            class => 'Error',
            text  => $P{'error'},
        ),
    }

    push @{ $self->{'FormContent'} }, $self->make_Container(
        class   => $P{'name'},
        content => \@content,
    );

    return;
} # }}}

sub add_SelectEntry { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            name    => { type=>SCALAR },
            caption => { type=>SCALAR },
            value   => { type=>SCALAR },
            options => { type=>ARRAYREF },
            error   => { type=>SCALAR | UNDEF, optional=>1 },
        }
    );

    my @content = (
        $self->make_Label(
            class => 'name',
            text  => $P{'caption'},
        ),
        $self->make_SelectEntry(
            class   => 'value',
            name    => $P{'name'},
            value   => $P{'value'},
            options => $P{'options'},
        ),
    );
    if ($P{'error'}) {
        push @content, $self->make_Label(
            class => 'Error',
            text  => $P{'error'},
        ),
    }

    push @{ $self->{'FormContent'} }, $self->make_Container(
        class   => $P{'name'},
        content => \@content,
    );

    return;
} # }}}

sub add_FileEntry { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            name    => { type=>SCALAR },
            caption => { type=>SCALAR },
            error   => { type=>SCALAR | UNDEF, optional=>1 },
        }
    );
    
    my @content = (
        $self->make_Label(
            class => 'name',
            text  => $P{'caption'},
        ),
        $self->make_FileEntry(
            class => 'value',
            name  => $P{'name'},
        ),
    );
    if ($P{'error'}) {
        push @content, $self->make_Label(
            class => 'Error',
            text  => $P{'error'},
        ),
    }

    push @{ $self->{'FormContent'} }, $self->make_Container(
        class   => $P{'name'},
        content => \@content,
    );

    return;
} # }}}

sub add_Check { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            name    => { type=>SCALAR },
            caption => { type=>SCALAR },
            checked => { type=>SCALAR },
#            error   => { type=>SCALAR | UNDEF, optional=>1 },
        }
    );
    
    my @content = (
        $self->make_Check(
            class   => 'check',
            name    => $P{'name'},
            checked => $P{'checked'},
        ),
        $self->make_Label(
            class => 'name',
            text  => $P{'caption'},
        ),
    );
#    if ($P{'error'}) {
#        push @content, $self->make_Label(
#            class => 'Error',
#            text  => $P{'error'},
#        ),
#    }

    push @{ $self->{'FormContent'} }, $self->make_Container(
        class   => $P{'name'},
        content => \@content,
    );

    return;
} # }}}

sub add_Label { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            text  => { type=>SCALAR },
            class => { type=>SCALAR, optional=>1, default=>'Label' },
        }
    );

    push @{ $self->{'FormContent'} }, $self->make_Container(
        content => [
            $self->make_Label(
                class => $P{'class'},
                text  => $P{'text'},
            ),
        ]
    );

    return;
} # }}}

sub add_Action { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            caption => { type=>SCALAR },
            href    => { type=>SCALAR },
            class   => { type=>SCALAR, optional=>1, default=>'Label' },
        }
    );

    push @{ $self->{'FormContent'} }, $self->make_Container(
        content => [
            $self->make_Action(
                class   => $P{'class'},
                caption => $P{'caption'},
                href    => $P{'href'},
            ),
        ]
    );

    return;
} # }}}

# vim: fdm=marker
1;
