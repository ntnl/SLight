package SLight::Handler::System::Permissions::View;
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
use SLight::API::Permissions qw( get_System_access );
use SLight::Core::L10N qw( TR TF );
use SLight::DataStructure::List;
use SLight::DataStructure::List::Table;
use SLight::DataToken qw( mk_Link_token );
use SLight::HandlerMeta;
# }}}

# FIXME:
# - add permissions overview
# - add avatar
# - add toolbox
# - add path

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_System_Permissions');

    my $level_list = SLight::DataStructure::List->new(
        columns => [
            {
                caption => TR('Label'),
                name    => q{label},
            },
            {
                caption => TR('Description'),
                name    => q{desc},
            },
        ],
    );

    $level_list->add_Row(
        class => 'System',
        data  => {
            label => mk_Link_token(
                text => TR('System'),
                href => $self->build_url(
                    step => 'system',
                ),
            ),
            desc => TR('Policies applicable for both authenticated and non-authernticated Users.'),
        },
    );
    $level_list->add_Row(
        class => 'Guest',
        data  => {
            label => mk_Link_token(
                text => TR('Guest'),
                href => $self->build_url(
                    step => 'guest',
                ),
            ),
            desc => TR('Policies applicable for both non-authernticated Users.'),
        },
    );
    $level_list->add_Row(
        class => 'Authenticated',
        data  => {
            label => mk_Link_token(
                text => TR('Authenticated'),
                href => $self->build_url(
                    step => 'authenticated',
                ),
            ),
            desc => TR('Policies applicable for both authenticated Users.'),
        },
    );

    $self->push_data($level_list);

    return;
} # }}}

sub handle_system { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_System_Permissions');

    $self->_permissions('system');

    return;
} # }}}

sub handle_guest { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_System_Permissions');

    $self->_permissions('guest', 'system');

    return;
} # }}}

sub handle_authenticated { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_System_Permissions');

    $self->_permissions('authenticated', 'system');

    return;
} # }}}

sub _permissions { # {{{
    my ( $self, $level, @other_levels ) = @_;

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
        if (not $self->_row($table, $level, $family->{'class'}, q{*}, q{*})) {
            next;
        }

        foreach my $object (@{ $family->{'objects'} }) {
            if (not $self->_row($table, $level, $family->{'class'}, $object->{'class'}, q{*})) {
                next;
            }

            foreach my $action (@{ $object->{'actions'} }) {
                if (not $self->_row($table, $level, $family->{'class'}, $object->{'class'}, $action)) {
                    next;
                }
            }
        }
    }

    $self->push_data($table);

    return;
} # }}}

sub _row { # {{{
    my ( $self, $table, $level, $family, $class, $action ) = @_;

    my $display_inner = 1;

    my $label = $family .q{::}. $class .q{::}. $action;

    # Prepare stuff for this object class.
    my $policy_label;
    my $notes        = q{};
    my $actions      = q{};

    if ($level ne 'system') {
        # Check 'system' settings first.
        my $access_policy = get_System_access(
            type => q{system},

            handler_family => $family,
            handler_class  => $class,
            handler_action => $action,
        );

        if ($access_policy) {
            $policy_label = TF(q{%s on system level}, undef, $access_policy);
    
            $display_inner = 0;
        }
    }

    if (not $policy_label) {
        # OK, so the 'system' check was not conclusive.
        my $access_policy = get_System_access(
            type => $level,

            handler_family => $family,
            handler_class  => $class,
            handler_action => $action,
        );

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
                        level => $level,
            
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
                        level => $level,
            
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
                    level => $level,
            
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
