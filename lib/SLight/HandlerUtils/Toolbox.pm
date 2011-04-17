package SLight::HandlerUtils::Toolbox;
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
use strict; use warnings; use utf8; # {{{

use SLight::API::Permissions qw( can_User_access );
use SLight::Core::URL;
use SLight::Core::L10N qw( TR TF );
use SLight::DataToken qw( mk_Container_token mk_Action_token );
use SLight::PathHandlerUtils;

use Carp::Assert::More qw( assert_defined );
use Params::Validate qw( :all );
# }}}

# Toolbox renderer.

# Purpose:
#   Prepare an 'advanced' toolbox, where labels can be customized,
#   and each action can refer to different package/handler/path combination.
sub make_toolbox { # {{{
    my %P = validate(
        @_,
        {
            user_id => { type=>SCALAR, optional=>1 },

            urls => { type=>ARRAYREF },

            path_handler => { type=>SCALAR, optional=>1 },
            path         => { type=>ARRAYREF, optional=>1 },
            add_to_path  => { type=>ARRAYREF, optional=>1 },

            options  => { type=>HASHREF, optional=>1 },

            action => { type=>SCALAR, optional=>1 },
            step   => { type=>SCALAR, optional=>1 },
            lang   => { type=>SCALAR, optional=>1 },
            page   => { type=>SCALAR, optional=>1 },

            protocol => { type=>SCALAR, optional=>1 },

            class => { type=>SCALAR },
        }
    );

#    use Data::Dumper; warn 'Toolbox: ' . Dumper \%P;

    # Now, do the checks...
    my @action_buttons;
    foreach my $url (@{ $P{'urls'} }) {
        # Apply defaults:
        foreach my $field (qw( path_handler path action step lang page protocol options )) {
            if (not defined $url->{$field} and $P{$field}) {
                $url->{$field} = $P{$field};

                assert_defined($url->{$field}, $field . " configured");
            }
        }

        if ($P{'add_to_path'}) {
            $url->{'path'} = [
                @{ $P{'path'} },
                @{ $P{'add_to_path'} },
            ];
        }

        assert_defined($url->{'action'}, "action configured");

        my $class_and_id = SLight::PathHandlerUtils::get_path_target($url->{'path_handler'}, $url->{'path'});
        if ($class_and_id) {
#            use Data::Dumper; warn Dumper $url;
#            use Data::Dumper; warn Dumper $class_and_id;

            my ($handler_family, $handler_class) = split /::/, $class_and_id->{'handler'};

            # Check access rights, we have enough data for it to be possible.
            my $access_policy = can_User_access(
                id => $P{'user_id'},

                handler_family => $handler_family,
                handler_class  => $handler_class,

                handler_action => $url->{'action'},

                handler_object => $class_and_id->{'id'},
            );
            if ($access_policy ne q{GRANTED}) {
                next;
            }
        }

        my $caption = ( delete $url->{'caption'} or TR(ucfirst $url->{'action'} . q{#action}) );
        my $class   = ( delete $url->{'class'}   or q{SLight_} . ( ucfirst $url->{'action'} ) . q{_Action} );

        my $action_link = SLight::Core::URL::make_url(%{ $url });

        push @action_buttons, mk_Action_token(
            class   => $class,
            caption => $caption,
            href    => $action_link,
        );
    }

#    use Data::Dumper; warn 'Action buttons: '. Dumper \@action_buttons;

    if (scalar @action_buttons) {
        return mk_Container_token(
            class   => $P{'class'},
            content => \@action_buttons,
        );
    }

    return;
} # }}}

# vim: fdm=marker
1;
