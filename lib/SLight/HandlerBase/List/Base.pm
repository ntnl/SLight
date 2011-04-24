package SLight::HandlerBase::List::Base;
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
use base q{SLight::Handler};

use SLight::Core::L10N qw( TR TF );
use SLight::API::ContentSpec qw( get_ContentSpec );
use SLight::API::Page qw( get_Page_full_path );
use SLight::API::Asset qw( get_Asset_ids_on_Content get_Asset_ids_on_Content_Field get_Asset );
use SLight::API::Util qw( human_readable_size );
use SLight::DataToken qw( mk_Link_token mk_Label_token mk_Container_token mk_Text_token mk_ListItem_token mk_Image_token );
use SLight::DataType;

use Carp::Assert::More qw( assert_defined assert_hashref assert_listref );
use Params::Validate qw( :all );
# }}}



# vim: fdm=marker
1;
