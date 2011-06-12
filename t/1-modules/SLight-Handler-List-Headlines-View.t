#!/usr/bin/perl
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
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use SLight::HandlerMetaFactory;
use SLight::API::Content qw( add_Content );
use SLight::Test::Site;
use SLight::Test::Handler qw( run_handler_tests );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Minimal'
);

my $hmf = SLight::HandlerMetaFactory->new();
my $hm = $hmf->make(pkg => 'List', handler => 'Headlines');
my $spec = $hm->get_spec();

add_Content(
    Content_Spec_id => $spec->{'id'},

    status => q{V},
    Page_Entity_id => 1,

    on_page_index => 2,

    email => q{test@example.test},

    comment_write_policy => 0,
    comment_read_policy  => 0,

    added_time    => q{2011-04-23 12:30:00},
    modified_time => q{2011-04-23 12:30:00},
);

my @tests = (
    {
        'name' => q{Headlines on front page},
        'url'  => q{/},
    },
);

run_handler_tests(
    tests => \@tests,

    strip_dates => 1,

    skip_permissions => 1,
);

# vim: fdm=marker
