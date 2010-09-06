package SLight::DataStructure;
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

# Handler of generic DataStructure, and base code for specialized SataStructure objects.
use strict; use warnings; # {{{

use Params::Validate qw( :all );
# }}}

sub new { # {{{
    my ( $class, %P ) = @_;

    my $self = {
        data => undef,
    };

    bless $self, $class;

    $self->_new(%P);

    return $self;
} # }}}

# Childs may wish to overwrite this.
sub _new { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
        }
    );

    return;
} # }}}

# Set data stored in Response handler.
sub set_data { # {{{
    my ( $self, $data ) = @_;

    # Todo: some validation would be nice.

    return $self->{'data'} = $data;
} # }}}

# Return data prepared by Response handler.
sub get_data { # {{{
    my ( $self ) = @_;
    
    confess_on_false($self->{'data'}, "Data was not prepared!");

    return $self->{'data'};
} # }}}

# Utility functions

# If given 'object' is a scalar, make Label from it.
# Returns either one element array (scalar context) or Label hash.
#
# If it is a reference, just return it.
#
# Especially handy for making simple tables/grids or other simple elements.
sub make_label_if_text { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class  => { type=>SCALAR, optional=>1, default=>'generic' },
            object => { }
        }
    );

    if (ref $P{'object'}) {
        return $P{'object'};
    }

    return [
        $self->make_Label(
            text  => $P{'object'},
            class => $P{'class'}
        )
    ];
} # }}}

# Functions that validate/create hashref for Response Elements.

sub make_List { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class   => { type=>SCALAR, optional=>1, default=>'generic' },
            content => { type=>ARRAYREF }
        }
    );

    $P{'type'} = 'List';

    return \%P;
} # }}}
sub make_GridItem { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class   => { type=>SCALAR, optional=>1, default=>'generic' },
            content => { type=>ARRAYREF },
        }
    );

    $P{'type'} = 'GridItem';

    return \%P;
} # }}}
sub make_Grid { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class   => { type=>SCALAR, optional=>1, default=>'generic' },
            content => { type=>ARRAYREF },
        }
    );

    $P{'type'} = 'Grid';

    return \%P;
} # }}}
sub make_TextEntry { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class => { type=>SCALAR, optional=>1, default=>'generic' },
            value => { type=>SCALAR, optional=>1, default=>q{} },
            name  => { type=>SCALAR },
        }
    );
    
    $P{'type'} = 'TextEntry';
    
    $P{'data'}->{'name'}  = delete $P{'name'};
    $P{'data'}->{'value'} = delete $P{'value'};

    return \%P;
} # }}}
sub make_Entry { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class => { type=>SCALAR, optional=>1, default=>'generic' },
            value => { type=>SCALAR, optional=>1, default=>q{} },
            name  => { type=>SCALAR },
        }
    );
    
    $P{'type'} = 'Entry';
    
    $P{'data'}->{'name'}  = delete $P{'name'};
    $P{'data'}->{'value'} = delete $P{'value'};

    return \%P;
} # }}}
sub make_FileEntry { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class => { type=>SCALAR, optional=>1, default=>'generic' },
            name  => { type=>SCALAR },
        }
    );
    
    $P{'type'} = 'FileEntry';
    
    $P{'data'}->{'name'}  = delete $P{'name'};

    return \%P;
} # }}}
sub make_PasswordEntry { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class => { type=>SCALAR, optional=>1, default=>'generic' },
            value => { type=>SCALAR, optional=>1, default=>q{} },
            name  => { type=>SCALAR },
        }
    );
    
    $P{'type'} = 'PasswordEntry';

    $P{'data'}->{'name'}  = delete $P{'name'};
    $P{'data'}->{'value'} = delete $P{'value'};

    return \%P;
} # }}}
sub make_Status { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class  => { type=>SCALAR, optional=>1, default=>'generic' },
            status => { type=>SCALAR, optional=>1, default=>q{} }
        }
    );

    $P{'type'} = 'Status';
    $P{'data'}->{'status'} = delete $P{'status'};

    return \%P;
} # }}}
# WIP
#sub make_Radio { # {{{
#    my $self = shift;
#    my %P = validate(
#        @_,
#        {
#        }
#    );
#
#    return \%P;
#} # }}}
sub make_Label { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class => { type=>SCALAR, optional=>1, default=>'generic' },
            text  => { type=>SCALAR, optional=>1, default=>q{} }
        }
    );

    $P{'type'} = 'Label';
    $P{'data'}->{'text'} = delete $P{'text'};

    return \%P;
} # }}}
sub make_Text { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class => { type=>SCALAR, optional=>1, default=>'generic' },
            text  => { type=>SCALAR | ARRAYREF, optional=>1, default=>q{} }
        }
    );

    $P{'type'} = 'Text';
    $P{'data'}->{'text'} = delete $P{'text'};

    return \%P;
} # }}}
sub make_SelectEntry { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class   => { type=>SCALAR, optional=>1, default=>'generic' },
            value   => { type=>SCALAR, optional=>1, default=>q{} },
            options => { type=>ARRAYREF },
            name    => { type=>SCALAR },
        }
    );
    
    $P{'type'} = 'SelectEntry';
    
    $P{'data'}->{'name'}    = delete $P{'name'};
    $P{'data'}->{'value'}   = delete $P{'value'};
    $P{'data'}->{'options'} = delete $P{'options'};

    return \%P;
} # }}}
# WIP
#sub make_Counter { # {{{
#    my $self = shift;
#    my %P = validate(
#        @_,
#        {
#        }
#    );
#
#    return \%P;
#} # }}}
sub make_Container { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class   => { type=>SCALAR, optional=>1, default=>'generic' },
            content => { type=>ARRAYREF }
        }
    );

    $P{'type'} = 'Container';

    return \%P;
} # }}}
sub make_Form { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class   => { type=>SCALAR, optional=>1, default=>'generic' },
            hidden  => { type=>HASHREF, optional=>1, },
            action  => { type=>SCALAR },
            submit  => { type=>SCALAR },
            content => { type=>ARRAYREF }
        }
    );

    $P{'type'} = 'Form';
    $P{'data'} = {
        hidden => delete $P{'hidden'},
        action => delete $P{'action'},
        submit => delete $P{'submit'},
    };

    return \%P;
} # }}}
sub make_Link { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class => { type=>SCALAR, optional=>1, default=>'generic' },
            text  => { type=>SCALAR },
            href  => { type=>SCALAR },
        }
    );

    $P{'type'} = 'Link';
    $P{'data'}->{'text'} = delete $P{'text'};
    $P{'data'}->{'href'} = delete $P{'href'};

    return \%P;
} # }}}
sub make_Action { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class => { type=>SCALAR, optional=>1, default=>'generic' },
            caption => { type=>SCALAR },
            href    => { type=>SCALAR },
        }
    );

    $P{'type'} = 'Action';
    $P{'data'}->{'caption'} = delete $P{'caption'};
    $P{'data'}->{'href'}    = delete $P{'href'};

    return \%P;
} # }}}
sub make_Image { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class => { type=>SCALAR, optional=>1, default=>'generic' },
            href  => { type=>SCALAR },
            label => { type=>SCALAR, optional=>1, default=>q{} },
        }
    );
    
    $P{'type'} = 'Image';
    
    $P{'data'}->{'href'}  = delete $P{'href'};
    $P{'data'}->{'label'} = delete $P{'label'};

    return \%P;
} # }}}
# WIP:
#sub make_ProgressBar { # {{{
#    my $self = shift;
#    my %P = validate(
#        @_,
#        {
#        }
#    );
#
#    return \%P;
#} # }}}
sub make_Check { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class   => { type=>SCALAR, optional=>1, default=>'generic' },
            checked => { type=>SCALAR, optional=>1, default=>0 },
            name    => { type=>SCALAR },
        }
    );
    
    $P{'type'} = 'Check';
    
    $P{'data'}->{'name'}    = delete $P{'name'};
    $P{'data'}->{'checked'} = delete $P{'checked'};

    return \%P;
} # }}}
sub make_ListItem { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class   => { type=>SCALAR, optional=>1, default=>'generic' },
            content => { type=>ARRAYREF }
        }
    );

    $P{'type'} = 'ListItem';

    return \%P;
} # }}}
sub make_Table { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class   => { type=>SCALAR, optional=>1, default=>'generic' },
            content => { type=>ARRAYREF },
        }
    );
    
    $P{'type'} = 'Table';

    return \%P;
} # }}}
sub make_TableRow { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class   => { type=>SCALAR, optional=>1, default=>'generic' },
            content => { type=>ARRAYREF },
        }
    );

    $P{'type'} = 'TableRow';

    return \%P;
} # }}}
sub make_TableCell { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            class   => { type=>SCALAR, optional=>1, default=>'generic' },
            content => { type=>ARRAYREF },
            colspan => { type=>SCALAR, optional=>1, default=>0 },
            rowspan => { type=>SCALAR, optional=>1, default=>0 },
        }
    );

    $P{'type'} = 'TableCell';
    
    $P{'data'}->{'colspan'} = delete $P{'colspan'};
    $P{'data'}->{'rowspan'} = delete $P{'rowspan'};

    return \%P;
} # }}}

# vim: fdm=marker
1;
