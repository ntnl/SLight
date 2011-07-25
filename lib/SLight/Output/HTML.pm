package SLight::Output::HTML;
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
use base q{SLight::Output};

use SLight::Core::Config;
use SLight::Output::HTML::Template;

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use File::Slurp qw( read_file );
use Params::Validate qw( :all );
# }}}

my %known_addons = (
    'slight.core.path.addon'     => q{Core::Path},
    'slight.core.language.addon' => q{Core::Language},
    'slight.core.sysinfo.addon'  => q{Core::Sysinfo},
    'slight.core.toolbox.addon'  => q{Core::Toolbox},
    'slight.core.debug.addon'    => q{Core::Debug},

    'slight.cms.rootmenu.addon' => q{CMS::Rootmenu},
    'slight.cms.menu.addon'     => q{CMS::Menu},
    'slight.cms.submenu.addon'  => q{CMS::Submenu},

    'slight.user.info.addon'  => q{User::Info},
    'slight.user.panel.addon' => q{User::Panel},
);

sub prepare { # {{{
    my ( $self, $template_code ) = @_;

    $self->{'template'} = SLight::Output::HTML::Template->new(
        name => $template_code,
        dir  => SLight::Core::Config::get_option('site_root') . q{/html/},
    );

    # If no template has been loaded, "do something" (FIXME) maybe auto-generate a template?

    return;
} # }}}

sub list_addons { # {{{
    my ( $self ) = @_;

    my @addons;

    foreach my $block (keys %known_addons) {
#        warn "Do We have $block?";

        if ($self->{'template'}->has_block($block)) {
            push @addons, $known_addons{$block};
        }
    }

    my $extra_addons = SLight::Core::Config::get_option('site_addons');
    if ($extra_addons) {
        foreach my $key (keys %{ $extra_addons }) {
            my $block = q{slight.} . $key . q{.addon};

            if ($self->{'template'}->has_block($block)) {
                push @addons, $extra_addons->{$key};
            }
        }
    }

#    warn "Add-ons found in template: ". join ", ", @addons;

    return @addons;
} # }}}

sub process_object_data { # {{{
    my ( $self, $oid, $data_structure ) = @_;

#    use Data::Dumper; warn q{process_object_data: } . Dumper $oid, $data_structure;

    $self->{'HTML'}->{'objects'}->{$oid} = $data_structure;

    return;
} # }}}

sub process_addon_data { # {{{
    my ( $self, $addon, $data_structure ) = @_;

#    use Data::Dumper; warn q{process_addon_data: } . Dumper $addon, $data_structure;

    my $addon_placeholder = $addon;
    $addon_placeholder =~ s{::}{\.}sg;

    $self->{'HTML'}->{'addons'}->{$addon_placeholder} = $data_structure;

    return;
} # }}}

sub serialize { # {{{
    my ( $self, $object_order, $template_code ) = @_;

    my @main_page_content;
    foreach my $oid (@{ $object_order }) {
        push @main_page_content, $self->{'HTML'}->{'objects'}->{$oid};
    }

#    use Data::Dumper; warn Dumper \@main_page_content;

    my $template = $self->{'template'};

    $template->set_layout(
        'content',
        {
            type    => 'Container',
            class   => 'SL_Content',
            content => \@main_page_content
        }
    );

    # Process Plugins. Each has it's own Layout block.
    foreach my $addon (keys %{ $self->{'HTML'}->{'addons'} }) {
        if ($self->{'HTML'}->{'addons'}->{$addon}) {
            $template->set_layout(
                q{slight.} . ( lc $addon ) .q{.addon},
                $self->{'HTML'}->{'addons'}->{$addon},
            );
        }
    }

    # Add some useful page-wide variables.
    $template->set_var('page_title', $self->{'metadata'}->{'title'});

    $template->set_var('web_root', SLight::Core::Config::get_option('web_root'));
    $template->set_var(
        'basehref',
        q{//} . SLight::Core::Config::get_option('domain') . SLight::Core::Config::get_option('web_root')
    );

    return (
       $template->render(),
        q{text/html; character-set: utf-8}
    );
} # }}}

# vim: fdm=marker
1;
