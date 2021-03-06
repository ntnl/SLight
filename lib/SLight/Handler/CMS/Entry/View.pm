package SLight::Handler::CMS::Entry::View;
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
use base q{SLight::HandlerBase::CMS};

use SLight::Core::L10N qw( TR );
use SLight::API::Content qw( get_Content );
use SLight::API::ContentSpec qw( get_ContentSpec );
use SLight::DataStructure::Token;
use SLight::DataStructure::Dialog::Notification;

use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

#    $self->push_data(
#        SLight::DataStructure::Dialog::Notification->new(
#            class => q{SL_Notification},
#            text  => q{This works!},
#        )
#    );

    my $Content = get_Content($oid, 1);

#    use Data::Dumper; warn $oid . ": ". Dumper $Content;

#    warn $Content->{'Spec.id'};

    my $Spec = get_ContentSpec($Content->{'Spec.id'});

    $self->set_class($Spec->{'class'});

    $self->push_data(
        $self->render_cms_page($Content, $Spec)
    );

    my $dump;
#    use Data::Dumper; $dump = 1;
    if ($dump) {
        $self->push_data(
            SLight::DataStructure::Dialog::Notification->new(
                class => q{SL_Notification},
                text  => q{<pre>} . ( Dumper $Content ) . q{</pre>},
            )
        );
    }

    $self->manage_toolbox($oid);

    return;
} # }}}

# vim: fdm=marker
1;
