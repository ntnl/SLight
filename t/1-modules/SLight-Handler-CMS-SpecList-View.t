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

use SLight::API::ContentSpec qw( add_ContentSpec );
use SLight::Test::Site;
use SLight::Test::Handler qw( run_handler_tests );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

my @tests = (
    {
        'name' => q{Empty list},
        'url'  => q{/_CMS_Spec/},
    },
    {
        'name'        => q{One element list},
        'url'         => q{/_CMS_Spec/},
        'call_before' => sub {
            add_ContentSpec(
                caption       => 'Woman',
                owning_module => 'CMS::Entry',
                version       => 0,
                cms_usage     => 1,

                class => 'Gal',

                order_by     => 60, # Ought to be the boobs size :)
                use_as_title => 10, # Full name
                use_in_menu  => 20, # Nick
                use_in_path  => 20,

                _data => { #             .-- ids explicitly added, to ensure, that fields get inserted in the RIGHT order.
                    full_name  => { id=>10, datatype => q{String}, caption => q{Name},       order => 1, default => q{},   max_length =>  75, translate => 0, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 1 },
                    nick       => { id=>20, datatype => q{String}, caption => q{Nick},       order => 2, default => q{},   max_length =>  45, translate => 0, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 1 },
                    chest_size => { id=>30, datatype => q{Int},    caption => q{Chest (cm)}, order => 3, default => q{90}, max_length => 250, translate => 0, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 1 },
                    waist_size => { id=>40, datatype => q{Int},    caption => q{Waist (cm)}, order => 4, default => q{60}, max_length => 250, translate => 0, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 1 },
                    hips_size  => { id=>50, datatype => q{Int},    caption => q{Hips (cm)},  order => 5, default => q{90}, max_length => 250, translate => 0, optional => 0, display_on_page => 1, display_on_list => 1, display_label => 1 },
                    cup_size   => { id=>60, datatype => q{String}, caption => q{Cup size},   order => 6, default => q{A},  max_length =>   1, translate => 0, optional => 0, display_on_page => 1, display_on_list => 0, display_label => 1 },
                },
            ),
        },
    }
);

run_handler_tests(
    tests => \@tests,

    skip_permissions => 1,
);

# vim: fdm=marker
