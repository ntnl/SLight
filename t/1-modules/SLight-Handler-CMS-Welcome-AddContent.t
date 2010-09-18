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
use SLight::Test::Handler qw( run_handler_tests );
use SLight::API::ContentSpec qw( add_ContentSpec );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

# Add some content specs:
my $spec1_id = add_ContentSpec(
    caption => 'Article',

    _data => {
        title   => { id=>10, caption=>'Title',   datatype=>'String', order=>1, default => q{}, translate=>1, max_length=>128 },
        article => { id=>11, caption=>'Article', datatype=>'Text',   order=>2, default => q{}, translate=>1, max_length=>1024 },
    },

    cms_usage => 3,

    owning_module => q{CMS::Entry},
);

my @tests = (
    {
        'name' => q{Get Content Spec choice menu},
        'url'  => q{/AddContent.web},
    },
    {
        'name' => q{Get form},
        'url'  => q{/AddContent-form.web},
        'cgi'  => {
            target  => 'New',
            spec_id => 1,
        },
    }
);

run_handler_tests(
    tests => \@tests,
    
    strip_dates => 1,
);

# vim: fdm=marker
