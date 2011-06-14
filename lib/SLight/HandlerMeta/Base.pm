package SLight::HandlerMeta::List;
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

use SLight::API::ContentSpec qw( get_ContentSpecs_where get_ContentSpec add_ContentSpec );
use SLight::Core::L10N qw( TR );

use Carp::Assert::More qw( assert_defined );
# }}}

sub new { # {{{
    my ( $class ) = @_;

    my $self = {};

    bless $self, $class;

    return $self;
} # }}}

sub check_spec { # {{{
    my ( $self, %P ) = @_;

    # Check, if there is a correct entry in Spec DB.
    my $stored_specs = get_ContentSpecs_where(
        owning_module => $P{'owning_module'},
        version       => $P{'version'},
    );

    if (scalar @{ $stored_specs }) {
#        warn "Stored";

#        use Data::Dumper; warn Dumper $stored_specs;

        return $stored_specs->[0];
    }

    my $added_spec_id = add_ContentSpec(%{ $P{'spec'} });

#    warn "Saved";

    return get_ContentSpec($added_spec_id);
} # }}}

# vim: fdm=marker
1;
