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

use SLight::Test::Site;
use SLight::API::Page;
use SLight::API::ContentSpec qw( add_ContentSpec );

use English qw( -no_match_vars );
use Test::More;
use Test::Exception;
# }}}

plan tests =>
    + 4 # add_Content
    + 2 # update_Content (miss-id and actual update)
    + 2 # update_Contents
    + 2 # get_Content
    + 2 # get_Contents
    + 2 # count_Contents_where
    + 2 # get_Content_ids_where
    + 2 # get_Contents_where
    + 2 # get_Contents_fields_where
    + 2 # delete_Content
    + 2 # delete_Contents
;

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

use SLight::API::Content qw(
    add_Content
    update_Content
    update_Contents
    get_Content
    get_Contents
    count_Contents_where
    get_Content_ids_where
    get_Contents_where
    get_Contents_fields_where
    delete_Content
    delete_Contents
);

# Prepare some Content Specs, on which we can work :)
my %ContentSpec_1 = (
    caption => 'Paintball gun',
    class   => 'TestStuff',
    _data   => { #      .-- usually this is not given, so DB creates it by itself...
        marker => { id=>10, caption => 'Marker Brand',     datatype  => 'String', order=>1, default => '', translate => 0, optional => 0, max_length => 250 },
        air    => { id=>20, caption => 'Gass type',        datatype  => 'String', order=>2, default => '', translate => 0, optional => 0, max_length => 250 },
        bps    => { id=>30, caption => 'Balls Per Second', datatype  => 'Int',    order=>3, default => '', translate => 0, optional => 0, max_length => 250 },
        note   => { id=>40, caption => 'Note',             datatype  => 'Text',   order=>4, default => '', translate => 1, optional => 0, max_length => 250 },
    },
    owning_module => 'Test::Test',
);
$ContentSpec_1{'id'} = add_ContentSpec(%ContentSpec_1); # 1

my ($f_marker, $f_air, $f_bps, $f_note ) = (10, 20, 30, 40);

my %ContentSpec_2 = (
    caption => 'Beautifull woman',
    class   => 'TestStuff',
    _data   => {
        name  => { id=>50, caption => 'Chest',    datatype => 'String', order=>1, default => '', translate => 0, optional => 0, max_length => 3 },
        chest => { id=>60, caption => 'Chest',    datatype => 'Int',    order=>2, default => '', translate => 0, optional => 0, max_length => 3 },
        waist => { id=>70, caption => 'Waist',    datatype => 'Int',    order=>3, default => '', translate => 0, optional => 0, max_length => 3 },
        hips  => { id=>80, caption => 'Hips',     datatype => 'Int',    order=>4, default => '', translate => 0, optional => 0, max_length => 3 },
        cup   => { id=>90, caption => 'Cup size', datatype => 'String', order=>5, default => '', translate => 0, optional => 0, max_length => 1 },
    },
    owning_module => 'Test::Test',
);
$ContentSpec_2{'id'} = add_ContentSpec(%ContentSpec_2); # 2

my ($f_name, $f_chest, $f_waist, $f_hips, $f_cup ) = (50, 60, 70, 80, 90);

my $p1 = SLight::API::Page::add_Page(
    parent_id => undef,
    path      => 'root',
);
my $p2 = SLight::API::Page::add_Page(
    parent_id => $p1,
    path      => 'Paintball',
);
my $p3 = SLight::API::Page::add_Page(
    parent_id => $p1,
    path      => 'Gals',
);

#
# run: add_Content
#
my ($c1, $c2, $c3, $c4);
is (
    $c1 = add_Content( # {{{
        Content_Spec_id => $ContentSpec_1{'id'},

        status => q{H},

        Page_Entity_id => $p2,

        on_page_index => 0,

        _data => {
            q{*} => {
                $f_marker => q{BT-4},
                $f_air    => q{CO2},
                $f_bps    => q{6},
            },
            en => {
                $f_note => q{Good old-school marker},
            },
            pl => {
                $f_note => q{Stara, dobra konstrukcja},
            },
        },

        metadata => {
            note_to_self => "First entry",
        }
    ),
    1,
    q{add_Content (1/4)} # }}}
);
is (
    $c2 = add_Content( # {{{
        Content_Spec_id => $ContentSpec_1{'id'},

        status => q{H},

        Page_Entity_id => $p2,

        on_page_index => 1,

        _data => {
            q{*} => {
                $f_marker => q{SP-1},
                $f_air    => q{HP},
                $f_bps    => q{10},
            },
            en => {
                $f_note => q{Good, affordable pneumatic marker},
            },
            pl => {
                $f_note => q{Niedrogi, marker pneumatyczny},
            }
        },

        metadata => {
            note_to_self => "Second entry",
        }
    ),
    2,
    q{add_Content (2/4)} # }}}
);
is (
    $c3 = add_Content( # {{{
        Content_Spec_id => $ContentSpec_2{'id'},

        status => q{H},

        Page_Entity_id => $p3,

        on_page_index => -1,

        _data => {
            q{*} => {
                $f_name  => q{Agnes},
                $f_chest => q{90},
                $f_waist => q{60},
                $f_hips  => q{90},
                $f_cup   => q{C},
            }
        },

        metadata => {
            note_to_self => "Third entry",
        }
    ),
    3,
    q{add_Content (3/4)} # }}}
);
is (
    $c4 = add_Content( # {{{
        Content_Spec_id => $ContentSpec_2{'id'},

        status => q{H},

        Page_Entity_id => $p3,

        on_page_index => 0,

        _data => {
            q{*} => {
                $f_name  => q{Wanda},
                $f_chest => q{85},
                $f_waist => q{65},
                $f_hips  => q{85},
                $f_cup   => q{B},
            }
        },

        metadata => {
            note_to_self => "Fourth entry",
        }
    ),
    4,
    q{add_Content (4/4)} # }}}
);

#
# run: update_Content (miss-id and actual update)
#
is(
    update_Content(
        id => 1234,

        status => q{A},

        _data => {
            q{*} => {
                $f_chest => q{88},
                $f_waist => q{54},
                $f_hips  => q{85},
            }
        },

        metadata => {
            note_to_self => "Third entry - updated",
        }
    ),
    undef,
    q{update_Content (1/2) - not existing ID}
);
is(
    update_Content(
        id => $c3,

        status => q{V},

        _data => {
            q{*} => {
                $f_chest => q{88},
                $f_waist => q{54},
                $f_hips  => q{85},
            }
        },

        metadata => {
            note_to_self => "Third entry - updated",
        }
    ),
    undef,
    q{update_Content (1/2)}
);

#
# run: update_Contents
#
is(
    update_Contents(
        ids => [ 123, 456 ],

        status => q{V}
    ),
    undef,
    q{update_Contents (1/2)}
);
is(
    update_Contents(
        ids => [ $c1, $c2 ],

        status => q{V}
    ),
    undef,
    q{update_Contents (2/2)}
);

#
# run: get_Content
#
is_deeply(
    [ get_Content(1234) ],
    [ ],
    q{get_Content (1/2) non-existing ID}
);
is_deeply(
    _date_is_sane(get_Content($c2)),
    {
        id => $c2,

        Content_Spec_id => $ContentSpec_1{'id'},

        status => q{V},

        Page_Entity_id => $p2,

        on_page_index => 1,

        _data => {
            q{*} => {
                $f_marker => q{SP-1},
                $f_air    => q{HP},
                $f_bps    => q{10},
            },
            q{en} => {
                $f_note => q{Good, affordable pneumatic marker},
            },
            pl => {
                $f_note => q{Niedrogi, marker pneumatyczny},
            },
        },
	
        comment_write_policy => 0,
        comment_read_policy  => 0,

        added_time    => q{#DATE IS SANE#},
        modified_time => q{#DATE IS SANE#},

        metadata => {
            note_to_self => "Second entry",
        }
    },
    q{get_Content (2/2) - existing ID}
);

#
# run: get_Contents
#
is_deeply(
    get_Contents( [123, 456] ),
    [],
    q{get_Contents (1/2) - non-existing IDs}
);
is_deeply(
    _dates_are_sane(get_Contents( [$c2, $c3] ) ),
    [
        {
            id => $c3,

            Content_Spec_id => $ContentSpec_2{'id'},

            status => q{V},

            Page_Entity_id => $p3,

            on_page_index => -1,

            _data => {
                q{*} => {
                    $f_name  => q{Agnes},
                    $f_chest => q{88},
                    $f_waist => q{54},
                    $f_hips  => q{85},
                    $f_cup   => q{C},
                }
            },

            comment_write_policy => 0,
            comment_read_policy  => 0,

            added_time    => q{#DATE IS SANE#},
            modified_time => q{#DATE IS SANE#},

            metadata => {
                note_to_self => "Third entry - updated",
            }
        },
        {
            id => $c2,

            Content_Spec_id => $ContentSpec_1{'id'},

            status => q{V},

            Page_Entity_id => $p2,

            on_page_index => 1,

            _data => {
                q{*} => {
                    $f_marker => q{SP-1},
                    $f_air    => q{HP},
                    $f_bps    => q{10},
                },
                en => {
                    $f_note => q{Good, affordable pneumatic marker},
                },
                pl => {
                    $f_note => q{Niedrogi, marker pneumatyczny},
                }
            },

            comment_write_policy => 0,
            comment_read_policy  => 0,

            added_time    => q{#DATE IS SANE#},
            modified_time => q{#DATE IS SANE#},

            metadata => {
                note_to_self => "Second entry",
            },
        },
    ],
    q{get_Contents (2/2) - existing IDs}
);

#
# run: count_Contents_where
#
is(
    count_Contents_where(
        status => q{A},
    ),
    0,
    q{count_Contents_where (1/2) - miss}
);
is(
    count_Contents_where(
        status => q{V},
    ),
    3,
    q{count_Contents_where (2/2) - hit}
);

#
# run: get_Content_ids_where
#
is_deeply(
    get_Content_ids_where(
        status => q{A},
    ),
    [ ],
    q{get_Contents_ids_where (1/2) - miss}
);
is_deeply(
    [
        sort @{
            get_Content_ids_where(
                status => q{V},
            )
        }
    ],
    [ $c1, $c2, $c3 ],
    q{get_Contents_ids_where (2/2) - hit}
);

#
# run: get_Contents_where
#
is_deeply(
    get_Contents_where(
        status => q{A},
    ),
    [],
    q{get_Contents_where (1/2) - miss}
);
is_deeply(
    _dates_are_sane(
        get_Contents_where(
            status => q{H},
        )
    ),
    [
        {
            id => $c4,

            Content_Spec_id => $ContentSpec_2{'id'},

            status => q{H},

            Page_Entity_id => $p3,

            on_page_index => 0,

            _data => {
                q{*} => {
                    $f_name  => q{Wanda},
                    $f_chest => q{85},
                    $f_waist => q{65},
                    $f_hips  => q{85},
                    $f_cup   => q{B},
                }
            },

            comment_write_policy => 0,
            comment_read_policy  => 0,

            added_time    => q{#DATE IS SANE#},
            modified_time => q{#DATE IS SANE#},

            metadata => {
                note_to_self => "Fourth entry",
            }
        }
    ],
    q{get_Contents_where (2/2) - hit}
);

#
# run: get_Contents_fields_where
#
is_deeply(
    get_Contents_fields_where(
        status => q{A},

        _fields => [ qw( status ) ],

        _data_lang => q{en},
    ),
    [],
    q{get_Contents_fields_where (1/2) - miss}
);
is_deeply(
    get_Contents_fields_where(
        status => q{H},

        _fields => [ qw( status ) ],

        _data_lang => q{en},
    ),
    [
        {
            id => $c4,

            status => q{H},

            _data => {
                q{*} => {
                    $f_name  => q{Wanda},
                    $f_chest => q{85},
                    $f_waist => q{65},
                    $f_hips  => q{85},
                    $f_cup   => q{B},
                }
            },

            metadata => {},
        }
    ],
    q{get_Contents_fields_where (2/2) - hit}
);

#
# run: delete_Content
#
is(
    delete_Content(1234),
    1,
    q{delete_Content (1/2) - miss}
);
is(
    delete_Content($c2),
    1,
    q{delete_Content (2/2) - hit}
);

#
# run: delete_Contents
#
is(
    delete_Contents( [ 123, 456 ] ),
    2,
    q{delete_Contents (1/2) - miss}
);
is(
    delete_Contents( [ $c3, $c4 ] ),
    2,
    q{delete_Contents (2/2) - hit}
);

sub _date_is_sane { # {{{
    my ( $stuff ) = @_;

    foreach my $field (qw( added_time modified_time )) {
        if ($stuff->{$field}) {
            $stuff->{$field} =~ s{\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d}{#DATE IS SANE#}sg;
        }
    }

    return $stuff;
} # }}}
sub _dates_are_sane {
    my ( $stuff ) = @_;

    foreach my $s (@{ $stuff }) {
        _date_is_sane($s);
    }

    return $stuff;
} # }}}

# vim: fdm=marker
