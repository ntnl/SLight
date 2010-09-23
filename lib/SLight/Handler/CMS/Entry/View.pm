package SLight::Handler::CMS::Entry::View;
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
use base q{SLight::HandlerBase::CMS};

use SLight::Core::L10N qw( TR );
use SLight::API::Content qw( get_Content );
use SLight::DataStructure::Token;
use SLight::DataStructure::Dialog::Notification;

use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

#    $self->push_data(
#        SLight::DataStructure::Dialog::Notification->new(
#            class => q{SLight_Notification},
#            text  => q{This works!},
#        )
#    );

    my $content = get_Content($oid);

    $self->push_data(
        $self->ContentData_2_details($content)
    );

    my $dump;
#    use Data::Dumper; $dump = 1;
    if ($dump) {
        $self->push_data(
            SLight::DataStructure::Dialog::Notification->new(
                class => q{SLight_Notification},
                text  => q{<pre>} . ( Dumper $content ) . q{</pre>},
            )
        );
    }

    my @common_toolbox = (
        {
            caption => TR('Edit'),
            action  => 'Edit',
        },
        {
            caption => TR('Delete'),
            action  => 'Delete',
        },
    );
    if ($self->is_main_object()) {
        $self->set_toolbox(
            [
                {
                    caption => TR('Add Content'),
                    action  => 'AddContent',
                },
                @common_toolbox,
            ]
        );
    }
    else {
        $self->push_toolbox(
            urls => \@common_toolbox,
            
            'add_to_path' => [ q{-ob-} . $oid ],
        );
    }

    return;
} # }}}

# vim: fdm=marker
1;
