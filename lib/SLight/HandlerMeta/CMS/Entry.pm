package SLight::HandlerMeta::CMS::Entry;
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
use base 'SLight::HandlerMeta::Base';

use SLight::API::ContentSpec qw( get_ContentSpecs_where get_ContentSpec );

use Carp::Assert::More qw( assert_defined );
# }}}

sub get_spec { # {{{
    my ( $self, $spec_id, $save ) = @_;

    assert_defined($spec_id);

    #use Data::Dumper; warn Dumper get_ContentSpec($spec_id);

    return get_ContentSpec($spec_id);
} # }}}

# vim: fdm=marker
1;
