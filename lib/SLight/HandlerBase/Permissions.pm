package SLight::HandlerBase::Permissions;
################################################################################
# 
# SLight - Lightweight Content Management System.
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
use base q{SLight::Handler};

use SLight::API::User;
use SLight::Core::L10N qw( TR TF );
use SLight::DataStructure::List;
use SLight::DataStructure::List::Table;
use SLight::DataToken qw( mk_Link_token );
use SLight::HandlerMeta;
# }}}

sub render_permissions { # {{{
    my ( $self, $cgi ) = @_;

    my $table = SLight::DataStructure::List::Table->new(
        columns => [
            {
                caption => TR('Module'),
                name    => q{module},
            },
            {
                caption => TR('Policy'),
                name    => q{policy},
            },
            {
                caption => TR('Notes'),
                name    => q{notes},
            },
            {
                caption => TR('Actions'),
                name    => q{actions},
            },
        ],
    );

    my $handlers_list = SLight::HandlerMeta::get_handlers_list();

    foreach my $family (@{ $handlers_list }) {
        if (not $self->_row($table, $family->{'class'}, q{*}, q{*}, $cgi)) {
            next;
        }

        foreach my $object (@{ $family->{'objects'} }) {
            if (not $self->_row($table, $family->{'class'}, $object->{'class'}, q{*}, $cgi)) {
                next;
            }

            foreach my $action (@{ $object->{'actions'} }) {
                if (not $self->_row($table, $family->{'class'}, $object->{'class'}, $action, $cgi)) {
                    next;
                }
            }
        }
    }

    $self->push_data($table);

    return;
} # }}}

sub _row { # {{{
    my ( $self, $table, $family, $class, $action, $cgi ) = @_;

    my $display_inner = 1;

    my $label = $family .q{::}. $class .q{::}. $action;

    # Prepare stuff for this object class.
    my $policy_label;
    my $notes        = q{};
    my $actions      = q{};

    my $inherited_policy = $self->get_inherited_policy($family, $class, $action);
    if ($inherited_policy) {
        $policy_label = TF(q{Inherited: %s}, undef, $inherited_policy);

        $display_inner = 0;
    }

    if (not $policy_label) {
        # OK, so the 'system' check was not conclusive.
        my $access_policy = $self->get_direct_policy($family, $class, $action);

        if ($access_policy) {
            $policy_label = TR($access_policy);

            $display_inner = 0;

            if ($access_policy eq 'DENIED') {
                $actions = $self->make_toolbox(
                    urls => [
                        {
                            caption => TR('Grant access'),
                            step    => 'grant',
                        },
                        {
                            caption => TR('Clear'),
                            step    => 'clear',
                        },
                    ],
                    action  => 'Change',
                    options => {
                        %{ $cgi },
            
                        h_family => $family,
                        h_class  => $class,
                        h_action => $action,
                    },
                );
            }
            else {
                $actions = $self->make_toolbox(
                    urls => [
                        {
                            caption => TR('Deny access'),
                            step    => 'deny',
                        },
                        {
                            caption => TR('Clear'),
                            step    => 'clear',
                        },
                    ],
                    action  => 'Change',
                    options => {
                        %{ $cgi },
            
                        h_family => $family,
                        h_class  => $class,
                        h_action => $action,
                    },
                );
            }
        }
        else {
            $policy_label = TR('Not set');
            
            $actions = $self->make_toolbox(
                urls => [
                    {
                        caption => TR('Grant access'),
                        step    => 'grant',
                    },
                    {
                        caption => TR('Deny access'),
                        step    => 'deny',
                    },
                ],
                action  => 'Change',
                options => {
                    %{ $cgi },
            
                    h_family => $family,
                    h_class  => $class,
                    h_action => $action,
                },
            );
        }
    }

    $table->add_Row(
        data => {
            module  => $label,
            policy  => $policy_label,
            notes   => $notes,
            actions => $actions,
        },
    );

    return $display_inner;
} # }}}

# vim: fdm=marker
1;
