package SLight::API::ContentSpec;
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
use base 'Exporter';

use SLight::Core::Entity;

use Params::Validate qw( :all );
# }}}

our @EXPORT_OK = qw(
    add_ContentSpec
);
our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

my $_handler = SLight::Core::Entity->new( # {{{
    base_table  => 'Content_Spec',
    child_table => 'Content_Spec_Field',
 
    child_key => 'class',

    has_metadata => 1,

    data_fields       => [qw( caption owning_module version )],
    child_data_fields => [qw( class order datatype caption default translate display_on_page display_on_list display_label optional max_length )],

    cache_namespage => 'SLight::API::ContentType',
); # }}}

sub add_ContentSpec { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    return $_handler->add_ENTITY(%P);
} # }}}

# vim: fdm=marker
1;
