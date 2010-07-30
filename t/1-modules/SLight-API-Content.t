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
use FindBin qw{ $Bin };
use lib $Bin .'/../../lib/';

use CoMe::Test::Site;
use CoMe::API::ContentType;

use English qw{ -no_match_vars };
use Test::More;
use Test::Exception;
# }}}

plan tests =>
;

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

use SLight::API::Content;

# SLight ends here!

my $Foo_ContentHandler_id = CoMe::Core::ContentHandler::get_ContentHandler_id(pkg=>'Test', handler=>'Foo', auto_create=>1);
my $Bar_ContentHandler_id = CoMe::Core::ContentHandler::get_ContentHandler_id(pkg=>'Test', handler=>'Bar', auto_create=>1);

CoMe::Core::DB::run_query( query=>'BEGIN TRANSACTION' );

# Prepare some Content Types, on which we can work :)
my %ContentType_1 = (
    caption => 'Paintball gun',
    status  => 'visible',
    fields  => {
        marker => { caption => 'Marker Brand',     datatype  => 'String', default => '',   translate => 0, display => 0, use_label => 0, optional => 0, max_length => 250 },
        balls  => { caption => 'Paintballs',       datatype  => 'String', default => '',   translate => 0, display => 1, use_label => 0, optional => 0, max_length => 250 },
        air    => { caption => 'Gass type',        datatype  => 'String', default => 'HP', translate => 1, display => 2, use_label => 0, optional => 0, max_length => 250 },
        bps    => { caption => 'Balls Per Second', datatype  => 'Int',    default => '',   translate => 0, display => 0, use_label => 0, optional => 0, max_length => 250 },
    },
    fields_order => [qw{ marker bps air balls }],
    role => {
        'title' => 'marker',
        'sort'  => 'bps',
    },
    ContentHandler_id => $Foo_ContentHandler_id
);
CoMe::Core::ContentType::set_one(%ContentType_1);
$ContentType_1{'id'} = 1;

my %ContentType_2 = (
    caption => 'Beautifull woman',
    status  => 'hidden',
    fields  => {
        chest => { caption => 'Chest',    datatype => 'Int',    default => '', translate => 0, display => 0, use_label => 0, optional => 0, max_length => 3 },
        waist => { caption => 'Waist',    datatype => 'Int',    default => '', translate => 0, display => 0, use_label => 0, optional => 0, max_length => 3 },
        hips  => { caption => 'Hips',     datatype => 'Int',    default => '', translate => 0, display => 0, use_label => 0, optional => 0, max_length => 3 },
        cup   => { caption => 'Cup size', datatype => 'String', default => '', translate => 0, display => 0, use_label => 0, optional => 0, max_length => 1 },
    },
    fields_order => [qw{ chest waist hips cup }],
    role => {
        'title' => 'chest',
        'sort'  => 'cup',
    },
    ContentHandler_id => $Foo_ContentHandler_id
);
CoMe::Core::ContentType::set_one(%ContentType_2);
$ContentType_2{'id'} = 2;

CoMe::Core::DB::run_query( query=>'END' );

# Test data used here.
# Motto is: Every Beautifull Woman needs a fast gun ;)
my @test_content = (
    {}, # Placeholder, to get rid of number 0
    { # id: 1
	    parent_id         => 0,
	    ContentType       => \%ContentType_2,
        ContentHandler_id => $Foo_ContentHandler_id,
        EmailMeta_id      => 5,

        path       => 'Beatrice',
	    status     => 'hidden',
        template   => '',
        comments   => 0,

	    data => { chest => 89, waist => 62, hips  => 92, cup   => 'C' },
    },
    { # id: 2
	    parent_id         => 0,
	    ContentType       => \%ContentType_2,
        ContentHandler_id => $Foo_ContentHandler_id,
        EmailMeta_id      => 5,

        path       => 'Monica',
	    status     => 'visible',
        template   => '',
        comments   => 5,

	    data => { chest => 75, waist => 58, hips  => 85, cup   => 'A' },
    },
    { # id: 3
	    parent_id         => 1,
	    ContentType       => \%ContentType_1,
        ContentHandler_id => $Foo_ContentHandler_id,
        EmailMeta_id      => 6,

        path       => 'ION',
	    status     => 'visible',
        template   => 'Paintgun',
        comments   => 3,

	    data => { marker => 'Ion XP', balls => 'Cactus Fun', air => 'HPA', bps => 16 },
    },
    { # id: 4
	    parent_id         => 1,
	    ContentType       => \%ContentType_1,
        ContentHandler_id => $Foo_ContentHandler_id,
        EmailMeta_id      => 6,

        path       => 'SP1',
	    status     => 'visible',
        template   => 'Paintgun',
        comments   => 3,

	    data => { marker => 'SP-1', balls => 'Cactus Colors', air => 'HPA', bps => 11 },
    },
    { # id: 5
	    parent_id         => 2,
	    ContentType       => \%ContentType_1,
        ContentHandler_id => $Foo_ContentHandler_id,
        EmailMeta_id      => 7,

        path       => 'T98',
	    status     => 'visible',
        template   => 'Paintgun',
        comments   => 3,

	    data => { marker => 'Tippman 98 Custom', balls => 'Tomahowk Field', air => 'CO2', bps => 6 },
    },
    { # id: 6
	    parent_id         => 2,
	    ContentType       => \%ContentType_1,
        ContentHandler_id => $Foo_ContentHandler_id,
        EmailMeta_id      => 7,

        path       => 'BT4',
	    status     => 'visible',
        template   => 'Paintgun',
        comments   => 3,

	    data => { marker => 'BT-4', balls => 'Zap', air => 'CO2', bps => 6 },
    },
);

my @test_content_fetched;
foreach my $item (@test_content) {
    # This will copy only first level of keys/values, but this is enough here.
    my %copied_item = %{ $item };

    if ($copied_item{'ContentType'}) {
        $copied_item{'ContentType_id'} = $copied_item{'ContentType'}->{'id'};
        delete $copied_item{'ContentType'};
    }

    push @test_content_fetched, \%copied_item;
}

my @a_result;
my $s_result;

# Real tests can begin now!

# On empty database...

is_deeply (
    scalar CoMe::Core::Content::get_one( id => 1 ),
    undef,
    'get_one by ID - scalar'
);
is_deeply (
    { CoMe::Core::Content::get_one( id => 1 ) },
    {
    },
    'get_one by ID - array'
);
is_deeply (
    scalar CoMe::Core::Content::get_one( path => '/Beatrice/SP1' ),
    undef,
    'get_one by Path - scalar'
);
is_deeply (
    { CoMe::Core::Content::get_one( path => '/Beatrice/SP1' ) },
    {
    },
    'get_one by ID - array'
);

# Insert something.

CoMe::Core::DB::run_query( query=>'END' );
CoMe::Core::DB::run_query( query=>'BEGIN' );

# Overwrite default time function, with something fixed:
$ENV{'TEST_TIMESTAMP_FUNC'} = q{'2009-01-14 21:45:00'};

ok ( [ CoMe::Core::Content::set_one(%{ $test_content[1] } ) ], 'set_one test 1 - in array context');
ok ( [ CoMe::Core::Content::set_one(%{ $test_content[2] } ) ], 'set_one test 2 - in array context');

# Advance in time, sedond addition:
$ENV{'TEST_TIMESTAMP_FUNC'} = q{'2009-01-14 21:47:00'};

ok ( CoMe::Core::Content::set_one(%{ $test_content[3] } ), 'set_one test 3 - in scalar context');
ok ( CoMe::Core::Content::set_one(%{ $test_content[4] } ), 'set_one test 4 - in scalar context');
ok ( CoMe::Core::Content::set_one(%{ $test_content[5] } ), 'set_one test 5 - in scalar context');
ok ( CoMe::Core::Content::set_one(%{ $test_content[6] } ), 'set_one test 6 - in scalar context');

CoMe::Core::DB::run_query( query=>'END' );

# Check path_for_id, while all data is still in DB

is ( CoMe::Core::Content::path_for_id(1), '/Beatrice/', 'path_for_id (1)');
is ( CoMe::Core::Content::path_for_id(2), '/Monica/',   'path_for_id (1)');

is ( CoMe::Core::Content::path_for_id(4), '/Beatrice/SP1/', 'path_for_id (4)');

is ( CoMe::Core::Content::path_for_id(42), q{}, 'path_for_id (42) - non existing');

# Get something.

is (
    CoMe::Core::Content::get_one( id => 1, ContentHandler_id=>123 ),
    undef,
    'get_one + ContentHandler_id check (non-cached)',
);
is_deeply (
    scalar CoMe::Core::Content::get_one( id => 1 ),
    {
        id => 1,

        %{ $test_content_fetched[1] },

        added_time    => q{2009-01-14 21:45:00},
        modified_time => q{2009-01-14 21:45:00},
        child_time    => q{2009-01-14 21:47:00},

        revision => 3,

        user  => 'UserX',
        email => q{x@foo-example.bar},
    },
    'get_one by ID - scalar'
);
is_deeply (
    { CoMe::Core::Content::get_one( id => 1 ) },
    {
        id => 1,

        %{ $test_content_fetched[1] },

        added_time    => q{2009-01-14 21:45:00},
        modified_time => q{2009-01-14 21:45:00},
        child_time    => q{2009-01-14 21:47:00},

        revision => 3,

        user  => 'UserX',
        email => q{x@foo-example.bar},
    },
    'get_one by ID - array'
);
is_deeply (
    scalar CoMe::Core::Content::get_one( path => '/Beatrice/SP1' ),
    {
        id => 4,

        %{ $test_content_fetched[4] },

        added_time    => q{2009-01-14 21:47:00},
        modified_time => q{2009-01-14 21:47:00},
        child_time    => q{2009-01-14 21:47:00},

        revision => 1,

        user  => 'UserZ',
        email => q{z@foo-example.bar},
    },
    'get_one by Path - scalar'
);
is_deeply (
    { CoMe::Core::Content::get_one( path => '/Beatrice/SP1' ) },
    {
        id => 4,

        %{ $test_content_fetched[4] },

        added_time    => q{2009-01-14 21:47:00},
        modified_time => q{2009-01-14 21:47:00},
        child_time    => q{2009-01-14 21:47:00},

        revision => 1,

        user  => 'UserZ',
        email => q{z@foo-example.bar},
    },
    'get_one by ID - array'
);

is (
    CoMe::Core::Content::get_one( id => 1, ContentHandler_id=>123 ),
    undef,
    'get_one + ContentHandler_id check (cached)',
);

# Update something.

# Test case: Monica has updated air to HPA:
$test_content[5]->{'comments'} = 2;
$test_content[6]->{'comments'} = 4;

$test_content[5]->{'data'}->{'air'} = 'HPA';
$test_content[6]->{'data'}->{'air'} = 'HPA';

$test_content_fetched[5]->{'data'}->{'air'} = 'HPA';
$test_content_fetched[6]->{'data'}->{'air'} = 'HPA';

# She also no longer wishes to say, what balls she is using...
delete $test_content[5]->{'data'}->{'balls'};
delete $test_content[6]->{'data'}->{'balls'};

delete $test_content_fetched[5]->{'data'}->{'balls'};
delete $test_content_fetched[6]->{'data'}->{'balls'};

CoMe::Core::DB::run_query( query=>'COMMIT' );
CoMe::Core::DB::run_query( query=>'BEGIN' );

# Advance in time, first update:
$ENV{'TEST_TIMESTAMP_FUNC'} = q{'2009-01-14 21:52:00'};

ok ( CoMe::Core::Content::set_one(id => 5, %{ $test_content[5] }), 'set_one test 5 - update');
ok ( CoMe::Core::Content::set_one(id => 6, %{ $test_content[6] }), 'set_one test 6 - update');

CoMe::Core::DB::run_query( query=>'COMMIT' );





# Fetch some list.
# (this will prove, if the change happened in DB)

# Cache needs this. Not sure why - must find cause, and remove the need for workaround.
system 'touch', '-t', '200012311800', $site_root .'/db/come.sqlite';

$s_result = CoMe::Core::Content::get_list( id => 2, ContentHandler_id => $Foo_ContentHandler_id );
is_deeply (
    [ sort { $a->{'id'} <=> $b->{'id'} } @{ $s_result } ],
    [
        {
            id => 5,

            %{ $test_content_fetched[5] },

            added_time    => q{2009-01-14 21:47:00},
            modified_time => q{2009-01-14 21:52:00},
            child_time    => q{2009-01-14 21:47:00},

            comments => 2,
            revision => 2,

            user  => 'UserY',
            email => q{y@foo-example.bar},
        },
        {
            id => 6,

            %{ $test_content_fetched[6] },

            added_time    => q{2009-01-14 21:47:00},
            modified_time => q{2009-01-14 21:52:00},
            child_time    => q{2009-01-14 21:47:00},

            comments => 4,
            revision => 2,

            user  => 'UserY',
            email => q{y@foo-example.bar},
        },
    ],
    'get_list by ID - scalar'
);
@a_result = CoMe::Core::Content::get_list( id => 2, ContentHandler_id => $Foo_ContentHandler_id );
is_deeply (
    [ sort { $a->{'id'} <=> $b->{'id'} } @a_result ],
    [
        {
            id => 5,

            %{ $test_content_fetched[5] },

            added_time    => q{2009-01-14 21:47:00},
            modified_time => q{2009-01-14 21:52:00},
            child_time    => q{2009-01-14 21:47:00},
            
            comments => 2,
            revision => 2,

            user  => 'UserY',
            email => q{y@foo-example.bar},
        },
        {
            id => 6,

            %{ $test_content_fetched[6] },

            added_time    => q{2009-01-14 21:47:00},
            modified_time => q{2009-01-14 21:52:00},
            child_time    => q{2009-01-14 21:47:00},
            
            comments => 4,
            revision => 2,

            user  => 'UserY',
            email => q{y@foo-example.bar},
        },
    ],
    'get_list by ID - array'
);
$s_result = CoMe::Core::Content::get_list( path => '/Beatrice', ContentHandler_id => $Foo_ContentHandler_id );
is_deeply (
    [ sort { $a->{'id'} <=> $b->{'id'} } @{ $s_result } ],
    [
        {
            id => 3,

            %{ $test_content_fetched[3] },

            added_time    => q{2009-01-14 21:47:00},
            modified_time => q{2009-01-14 21:47:00},
            child_time    => q{2009-01-14 21:47:00},
            
            revision => 1,

            user  => 'UserZ',
            email => q{z@foo-example.bar},
        },
        {
            id => 4,

            %{ $test_content_fetched[4] },

            added_time    => q{2009-01-14 21:47:00},
            modified_time => q{2009-01-14 21:47:00},
            child_time    => q{2009-01-14 21:47:00},
            
            revision => 1,

            user  => 'UserZ',
            email => q{z@foo-example.bar},
        },
    ],
    'get_list by Path - scalar'
);
@a_result = CoMe::Core::Content::get_list( path => '/Beatrice', ContentHandler_id => $Foo_ContentHandler_id );
is_deeply (
    [ sort { $a->{'id'} <=> $b->{'id'} } @a_result ],
    [
        {
            id => 3,

            %{ $test_content_fetched[3] },

            added_time    => q{2009-01-14 21:47:00},
            modified_time => q{2009-01-14 21:47:00},
            child_time    => q{2009-01-14 21:47:00},
            
            revision => 1,

            user  => 'UserZ',
            email => q{z@foo-example.bar},
        },
        {
            id => 4,

            %{ $test_content_fetched[4] },

            added_time    => q{2009-01-14 21:47:00},
            modified_time => q{2009-01-14 21:47:00},
            child_time    => q{2009-01-14 21:47:00},
            
            revision => 1,

            user  => 'UserZ',
            email => q{z@foo-example.bar},
        },
    ],
    'get_list by ID - array'
);

# Test 'get_counts'
is_deeply(
    CoMe::Core::Content::get_counts( ids => [ 0 ], ContentHandler_id => $Foo_ContentHandler_id ),
    {
        0 => 2
    },
    'get_counts on root'
);

is_deeply(
    CoMe::Core::Content::get_counts( ids => [ 1, 2 ], ContentHandler_id => $Foo_ContentHandler_id ),
    {
        1 => 2,
        2 => 2,
    },
    'get_counts on root items'
);

is_deeply(
    CoMe::Core::Content::get_counts( ids => [ 1, 2, 3, 4 ] ),
    {
        1 => 2,
        2 => 2,
    },
    'get_counts - stuff without childrens does not show'
);





# Update something with set_fields_data
CoMe::Core::DB::run_query( query=>'BEGIN TRANSACTION' );
lives_ok {
    CoMe::Core::Content::set_fields_data(
        id => 1,

        set_data => {
            hips => 88,
        },
    );
} 'set_fields_data - one update';

# Remove one field, so set_fields_data will have to run an INSERT.
CoMe::Core::DB::run_query( query=>q{DELETE FROM ContentEntryData WHERE ContentEntry_id=1 AND field = 'cup'});
lives_ok {
    CoMe::Core::Content::set_fields_data(
        id => 1,

        set_data => {
            chest => 91,
            cup   => 'D',
        },
    );
} 'set_fields_data - one update one insert';
CoMe::Core::DB::run_query( query=>'COMMIT' );

is_deeply (
    CoMe::Core::Content::get_one( id => 1 )->{'data'},
    {
        chest => 91,
        waist => 62,
        hips  => 88,

        cup => 'D',
    },
    'set_fields_data really changed the values.'
);



# Delete something.
ok ( CoMe::Core::Content::del( id => 1 ), 'del_one - Beatrice goes away');
ok ( CoMe::Core::Content::del( id => [ 5, 6 ] ), 'del_one - Monica abandons Paintball');







# Search for something.
# (this will prove, that deletion really happened in DB)

is_deeply (
    scalar CoMe::Core::Content::search(
        metadata => { path => 'Beat', },
        match    => 'like',
    ),
    undef,
    'search - no Beatrice any more'
);
is_deeply (
    [
        CoMe::Core::Content::search(
            metadata => { parent_id => 2 },
            data     => { air       => 'HPA' },
        )
    ],
    [ ],
    'search - no Paintball guns'
);

is_deeply (
    scalar CoMe::Core::Content::search(
        metadata => { ContentType_id => 2 },
    ),
    [
        {
            id => 2,

            %{ $test_content_fetched[2] },

            added_time    => q{2009-01-14 21:45:00},
            modified_time => q{2009-01-14 21:45:00},
            child_time    => q{2009-01-14 21:52:00}, # Thsi was altered when Monika upgraded to HPA
            
            revision => 5,

            user  => 'UserX',
            email => q{x@foo-example.bar},
        }
    ],
    'search - find all womans in the system - scalar context'
);
is_deeply (
    [
        CoMe::Core::Content::search(
            metadata => { ContentType_id => 2 },
        )
    ],
    [
        {
            id => 2,

            %{ $test_content_fetched[2] },

            added_time    => q{2009-01-14 21:45:00},
            modified_time => q{2009-01-14 21:45:00},
            child_time    => q{2009-01-14 21:52:00}, # Thsi was altered when Monika upgraded to HPA
            
            revision => 5,

            user  => 'UserX',
            email => q{x@foo-example.bar},
        }
    ],
    'search - find all womans in the system - array context'
);
is_deeply (
    scalar CoMe::Core::Content::search(
        metadata => { path => '%Moni%', },
        match    => 'like',
    ),
    [
        {
            id => 2,

            %{ $test_content_fetched[2] },

            added_time    => q{2009-01-14 21:45:00},
            modified_time => q{2009-01-14 21:45:00},
            child_time    => q{2009-01-14 21:52:00}, # Thsi was altered when Monika upgraded to HPA

            revision => 5,

            user  => 'UserX',
            email => q{x@foo-example.bar},
        }
    ],
    'search - Moni still there'
);

# Search (ids_only)
is_deeply (
    scalar CoMe::Core::Content::search(
        metadata => { path => '%Moni%', },
        match    => 'like',
        ids_only => 1,
    ),
    [ 2 ],
    'search - Moni still there (ids_only)'
);
is_deeply (
    scalar CoMe::Core::Content::search(
        metadata => { path => 'Moni', },
        ids_only => 1,
    ),
    [ ],
    'search - Moni still there (ids_only) not like, should miss'
);

is (CoMe::Core::Content::sort_callback({ data=>{foo=>0} }, { role=>{'sort'=>'foo'} }, { data=>{bar=>1} }, { role=>{'sort'=>'bar'} }, ), -1, 'sort_callback, number <');
is (CoMe::Core::Content::sort_callback({ data=>{foo=>1} }, { role=>{'sort'=>'foo'} }, { data=>{bar=>1} }, { role=>{'sort'=>'bar'} }, ),  0, 'sort_callback, number =');
is (CoMe::Core::Content::sort_callback({ data=>{foo=>1} }, { role=>{'sort'=>'foo'} }, { data=>{bar=>0} }, { role=>{'sort'=>'bar'} }, ),  1, 'sort_callback, number >');

is (CoMe::Core::Content::sort_callback({ data=>{foo=>'A'} }, { role=>{'sort'=>'foo'} }, { data=>{bar=>'B'} }, { role=>{'sort'=>'bar'} }, ), -1, 'sort_callback, letter <');
is (CoMe::Core::Content::sort_callback({ data=>{foo=>'C'} }, { role=>{'sort'=>'foo'} }, { data=>{bar=>'C'} }, { role=>{'sort'=>'bar'} }, ),  0, 'sort_callback, letter =');
is (CoMe::Core::Content::sort_callback({ data=>{foo=>'B'} }, { role=>{'sort'=>'foo'} }, { data=>{bar=>'A'} }, { role=>{'sort'=>'bar'} }, ),  1, 'sort_callback, letter >');

# vim: fdm=marker
