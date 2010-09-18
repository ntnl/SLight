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

# Generic Form DataStructure.
use strict; use warnings; # {{{
use base 'SLight::DataStructure';

use SLight::DataToken qw( mk_Form_token mk_Label_token mk_Entry_token mk_Container_token mk_TextEntry_token mk_SelectEntry_token );

use Params::Validate qw( :all );
# }}}

# Initialize the generic Form.
sub _new { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            action  => { type=>SCALAR },
            hidden  => { type=>HASHREF },
            submit  => { type=>SCALAR },
            preview => { type=>SCALAR, optional=>1 },
            class   => { type=>SCALAR, optional=>1, default=>'generic' },
        }
    );

    $self->{'FormContent'} = [];

    $self->set_data(
        mk_Form_token(
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
        mk_Label_token(
            class => 'Label',
            text  => $P{'caption'},
        ),
        mk_Entry_token(
            class => 'Value',
            name  => $P{'name'},
            value => $P{'value'},
        ),
    );
    if ($P{'error'}) {
        push @content, mk_Label_token(
            class => 'Error',
            text  => $P{'error'},
        ),
    }
    
    push @{ $self->{'FormContent'} }, mk_Container_token(
        class   => q{F-} . $P{'name'} . q{ Entry},
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
        mk_Label_token(
            class => 'Label',
            text  => $P{'caption'},
        ),
        mk_PasswordEntry_token(
            class => 'Value',
            name  => $P{'name'},
            value => $P{'value'},
        )
    );
    if ($P{'error'}) {
        push @content, mk_Label_token(
            class => 'Error',
            text  => $P{'error'},
        ),
    }

    push @{ $self->{'FormContent'} }, mk_Container_token(
        class   => q{F-} . $P{'name'} . q{ PasswordEntry},
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
        mk_Label_token(
            class => 'Label',
            text  => $P{'caption'},
        ),
        mk_TextEntry_token(
            class => 'Value',
            name  => $P{'name'},
            value => $P{'value'},
        ),
    );
    if ($P{'error'}) {
        push @content, mk_Label_token(
            class => 'Error',
            text  => $P{'error'},
        ),
    }

    push @{ $self->{'FormContent'} }, mk_Container_token(
        class   => q{F-} . $P{'name'} . q{ TextEntry},
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
        mk_Label_token(
            class => 'Label',
            text  => $P{'caption'},
        ),
        mk_SelectEntry_token(
            class   => 'Value',
            name    => $P{'name'},
            value   => $P{'value'},
            options => $P{'options'},
        ),
    );
    if ($P{'error'}) {
        push @content, mk_Label_token(
            class => 'Error',
            text  => $P{'error'},
        ),
    }

    push @{ $self->{'FormContent'} }, mk_Container_token(
        class   => q{F-} . $P{'name'} . q{ SelectEntry},
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
        mk_Label_token(
            class => 'Label',
            text  => $P{'caption'},
        ),
        mk_FileEntry_token(
            class => 'Value',
            name  => $P{'name'},
        ),
    );
    if ($P{'error'}) {
        push @content, mk_Label_token(
            class => 'Error',
            text  => $P{'error'},
        ),
    }

    push @{ $self->{'FormContent'} }, mk_Container_token(
        class   => q{F-} . $P{'name'} . q{ FileEntry},
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
        mk_Check_token(
            class   => 'Check',
            name    => $P{'name'},
            checked => $P{'checked'},
        ),
        mk_Label_token(
            class => 'Label',
            text  => $P{'caption'},
        ),
    );
#    if ($P{'error'}) {
#        push @content, mk_Label_token(
#            class => 'Error',
#            text  => $P{'error'},
#        ),
#    }

    push @{ $self->{'FormContent'} }, mk_Container_token(
        class   => q{F-} . $P{'name'} . q{ Check},
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

    push @{ $self->{'FormContent'} }, mk_Container_token(
        content => [
            mk_Label_token(
                class => q{F-} . $P{'class'} . q{ Label},
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

    push @{ $self->{'FormContent'} }, mk_Container_token(
        content => [
            mk_Action_token(
                class   => q{F-} . $P{'class'} . q{ Action},
                caption => $P{'caption'},
                href    => $P{'href'},
            ),
        ]
    );

    return;
} # }}}

# vim: fdm=marker
1;
