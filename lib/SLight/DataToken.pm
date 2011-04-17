package SLight::DataToken;
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
use base 'Exporter';

use Carp::Assert::More qw( assert_defined );
use Params::Validate qw( :all );
# }}}

our @EXPORT_OK = qw(
    mk_List_token
    mk_GridItem_token
    mk_Grid_token
    mk_TextEntry_token
    mk_Entry_token
    mk_FileEntry_token
    mk_PasswordEntry_token
    mk_Status_token
    mk_Label_token
    mk_Text_token
    mk_SelectEntry_token
    mk_Container_token
    mk_Form_token
    mk_Link_token
    mk_Action_token
    mk_Image_token
    mk_Check_token
    mk_ListItem_token
    mk_Table_token
    mk_TableRow_token
    mk_TableCell_token

    mk_ProgressBar_token
);
our %EXPORT_TAGS = (
    'all' => [ @EXPORT_OK ],
);

# Functions that create valid hashref-s for DataStructure.

sub mk_Container_token { # {{{
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

sub mk_List_token { # {{{
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
sub mk_ListItem_token { # {{{
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

sub mk_Grid_token { # {{{
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
sub mk_GridItem_token { # {{{
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

sub mk_Table_token { # {{{
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
sub mk_TableRow_token { # {{{
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
sub mk_TableCell_token { # {{{
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

sub mk_Form_token { # {{{
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
sub mk_Entry_token { # {{{
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
sub mk_TextEntry_token { # {{{
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
sub mk_FileEntry_token { # {{{
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
sub mk_PasswordEntry_token { # {{{
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
sub mk_SelectEntry_token { # {{{
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
sub mk_Check_token { # {{{
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

sub mk_Status_token { # {{{
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
sub mk_Label_token { # {{{
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
sub mk_Text_token { # {{{
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

sub mk_Link_token { # {{{
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
sub mk_Action_token { # {{{
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
sub mk_Image_token { # {{{
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

sub mk_ProgressBar_token { # {{{
    my %P = validate(
        @_,
        {
            class => { type=>SCALAR, optional=>1, default=>'generic' },

            bar_class => { type=>SCALAR, optional=>1, default=>'generic' },
            bar_value => { type=>SCALAR },
            bar_range => { type=>SCALAR },
        }
    );
    
    $P{'type'} = 'ProgressBar';

    $P{'data'}->{'bar_class'} = delete $P{'bar_class'};
    $P{'data'}->{'bar_value'} = delete $P{'bar_value'};
    $P{'data'}->{'bar_range'} = delete $P{'bar_range'};

    return \%P;
} # }}}

# WIP
#sub mk_Radio_token { # {{{
#    my %P = validate(
#        @_,
#        {
#        }
#    );
#
#    return \%P;
#} # }}}
# WIP
#sub mk_Counter_token { # {{{
#    my %P = validate(
#        @_,
#        {
#        }
#    );
#
#    return \%P;
#} # }}}

# vim: fdm=marker
1;
