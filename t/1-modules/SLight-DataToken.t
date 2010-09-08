#!/usr/bin/perl
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
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use English qw( -no_match_vars );
use Test::More;
use Test::FileReferenced;
# }}}

use SLight::DataToken qw(
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
);

plan tests =>
    + 21 # just check if all the routines are runnable.
;

is_referenced_ok(
    mk_List_token(
        content => [qw( Foo List Bar )],
    ),
    'mk_List_token'
);
is_referenced_ok(
    mk_ListItem_token(
        content => [qw( Foo ListItem Bar )],
    ),
    'mk_ListItem_token'
);

is_referenced_ok(
    mk_Grid_token(
        content => [qw( Foo Grid Bar )],
    ),
    'mk_Grid_token'
);
is_referenced_ok(
    mk_GridItem_token(
        content => [qw( Foo GridItem Bar )],
    ),
    'mk_GridItem_token'
);

is_referenced_ok(
    mk_Entry_token(
        name => 'entry1',
    ),
    'mk_Entry_token'
);
is_referenced_ok(
    mk_TextEntry_token(
        name => 'text1',
    ),
    'mk_TextEntry_token'
);
is_referenced_ok(
    mk_SelectEntry_token(
        name    => 'select1',
        options => [qw( O1 O2 O3 )]
    ),
    'mk_SelectEntry_token'
);
is_referenced_ok(
    mk_FileEntry_token(
        name => 'fale1',
    ),
    'mk_FileEntry_token'
);
is_referenced_ok(
    mk_Check_token(
        checked => 1,
        name    => 'check1',
    ),
    'mk_Check_token'
);
is_referenced_ok(
    mk_PasswordEntry_token(
        name => 'pass1',
    ),
    'mk_PasswordEntry_token'
);

is_referenced_ok(
    mk_Status_token(
        status => 'OK'
    ),
    'mk_Status_token'
);
is_referenced_ok(
    mk_Label_token(
        text => 'This is an usual label'
    ),
    'mk_Label_token'
);
is_referenced_ok(
    mk_Text_token(
        text => 'This is an usual text'
    ),
    'mk_Text_token'
);
is_referenced_ok(
    mk_Container_token(
        content => [qw( Foo Container Bar )],
    ),
    'mk_Container_token'
);
is_referenced_ok(
    mk_Form_token(
        content => [qw( Foo Form Bar )],
        submit  => 'Send out',
        action  => '/foo/bar/baz.cgi',
        hidden  => {
            yes => 1,
        }
    ),
    'mk_Form_token'
);
is_referenced_ok(
    mk_Link_token(
        text => 'This is a link',
        href => '/foo/bar/baz.html',
    ),
    'mk_Link_token'
);
is_referenced_ok(
    mk_Action_token(
        caption => 'This is an caption',
        href    => '/foo/bar/baz.html',
    ),
    'mk_Action_token'
);
is_referenced_ok(
    mk_Image_token(
        href  => '/foo/bar/baz.png',
        label => 'This is an image',
    ),
    'mk_Image_token'
);

is_referenced_ok(
    mk_Table_token(
        content => [qw( Foo Table Bar )],
    ),
    'mk_Table_token'
);
is_referenced_ok(
    mk_TableRow_token(
        content => [qw( Foo Row Bar )],
    ),
    'mk_TableRow_token'
);
is_referenced_ok(
    mk_TableCell_token(
        content => [qw( Foo Cell Bar )],
        colspan => 2,
        rowspan => 3,
    ),
    'mk_TableCell_token'
);

# vim: fdm=marker
