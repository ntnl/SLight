package SLight::Maintenance::Manipulate;
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

my $VERSION = '0.0.5';

use SLight::API::Content qw( add_Content update_Content get_Contents_where delete_Contents );
use SLight::API::ContentSpec qw( get_ContentSpec );
use SLight::API::Page qw( add_Page update_Page get_Page get_Page_id_for_path get_Pages_where delete_Page );
use SLight::Core::Config;
use SLight::Core::DB;
use SLight::DataType qw( decode_data encode_data );

use Cwd qw( getcwd );
use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use Encode qw( encode decode );
use File::Slurp qw( read_file write_file );
use Getopt::Long 2.36 qw( GetOptionsFromArray );
# }}}

my $_format;
my $_input;
my $_output;

sub main { # {{{
    my ( @params ) = @_;

    my %options = (
        'cms-list'   => q{},
        'cms-get'    => q{},
        'cms-set'    => q{},
        'cms-delete' => q{},
    );

    if (not scalar @params) {
        push @params, q{--help};
    }

    GetOptionsFromArray(
        \@params,

        'cms-list=s'   => \$options{'cms-list'},
        'cms-get=s'    => \$options{'cms-get'},
        'cms-set=s'    => \$options{'cms-set'},
        'cms-delete=s' => \$options{'cms-delete'},

        'format=s' => \$options{'format'},
        'input=s'  => \$options{'input'},
        'output=s' => \$options{'output'},

        'help'    => \$options{'help'},
        'version' => \$options{'version'},
    );

#    use Data::Dumper; warn Dumper \%options;

    if ($options{'version'}) {
        print "\n";
        print "SLight command line manipulation utility.\n";
        print "\n";
        print "SLight version: ". $VERSION ."\n";
        print "\n";

        return 0;
    }

    if ($options{'help'}) {
        print "\n";
        print "SLight command line manipulation utility.\n";
        print "\n";
        print "Usage:\n";
        print "  slight_manipulate [--option value]\n";
        print "\n";
        print "Options:\n";
        print "\n";
        print "  --cms-list /Path/   List CMS Page Entities bellow page /Path/\n";
        print "  --cms-get /Path/    Get CMS Entities on page /Path/\n";
        print "  --cms-set /Path/    Set CMS Entitys on page /Path/ (requires data input)\n";
        print "  --cms-delete /Path/ Delete page /Path/\n";
        print "\n";
        print "  --format zzz  Expect format to be in zzz (one of: XML, JSON or YAML)\n";
        print "  --input file  Read input data from file (default: read from STDIN)\n";
        print "  --output file Put output data into file (default: print to STDOUT)\n";
        print "\n";
        print "  --version Display version and exit.\n";
        print "  --help    Display (this) brief summary.\n";
        print "\n";

        return 0;
    }

    SLight::Core::Config::initialize( getcwd() );

    my %functionality = (
        'cms-list'   => \&handle_cms_list,
        'cms-get'    => \&handle_cms_get,
        'cms-delete' => \&handle_cms_delete,
        'cms-set'    => \&handle_cms_set,
    );

    $_format = lc ( delete $options{'format'} or q{yaml} );

    $_input  = ( delete $options{'input'} or q{-} );
    $_output = ( delete $options{'output'} or q{-} );

    SLight::Core::DB::check();

    foreach my $function (keys %functionality) {
        if ($options{$function}) {
            &{ $functionality{$function} }(\%options);
        }
    }

    # Happy end :)
    return 0;
} # }}}



# Initial implementation should fit one module.
# Later, when more stuff gets added, underlying functionality should probably be moved out.

sub pull_data { # {{{
    # Step one - load raw data.
    my $raw_data;
    if ($_input eq q{-}) {
        # Read from STDIN.
        $raw_data = read_file(\*STDIN);
    }
    else {
        $raw_data = read_file($_input);
    }

    # Step two - parse raw data.
    if ($_format eq 'yaml') {
        require YAML::Syck;

        return YAML::Syck::Load($raw_data);
    }
    if ($_format eq 'json') {
        require JSON::XS;

        return JSON::XS::decode_json($raw_data);
    }
    if ($_format eq 'xml') {
        require XML::Smart;

        my $XML = XML::Smart->new($raw_data);

        my $data = $XML->tree_ok();

        return _xml_strip_content($data->{'SLightRPC'});
    }

    # Unsupported data format :(
    # FIXME: warn the User!

    return;
} # }}}

sub push_data { # {{{
    my ( $data ) = @_;

    # Step one - serialize data into a string.
    my $string = q{};
    if ($_format eq 'yaml') {
        require YAML::Syck;

        $string = YAML::Syck::Dump($data);
    }
    elsif ($_format eq 'json') {
        require JSON::XS;

        $string = JSON::XS::encode_json($data);
    }
    elsif ($_format eq 'xml') {
        require XML::Smart;

        my $XML = XML::Smart->new(q{<?xml version="1.0" encoding="UTF-8" ?><SLightRPC></SLightRPC>});

        _xml_attach_hash($XML->{'SLightRPC'}, $data);

        $string = $XML->data(nometagen => 1);
    }

    # Step two - either print, or write to a file.
    if ($_output eq q{-}) {
        # Read from STDIN.
        print encode('utf8', $string);
    }
    else {
        write_file($_output, { binmode => ':raw' }, encode('utf8', $string));
    }

    return;
} # }}}

sub _xml_attach_hash { # {{{
    my ( $xml, $data ) = @_;

    foreach my $key (keys %{ $data }) {
        if (ref $data->{$key} eq 'HASH') {
            $xml->{$key} = {};

            _xml_attach_hash($xml->{$key}, $data->{$key});
        }
        elsif (ref $data->{$key} eq 'ARRAY') {
            $xml->{ $key } = [];

            _xml_attach_array($xml->{$key}, $data->{$key});
        }
        else {
            $xml->{$key} = $data->{$key};
        }

        $xml->{$key}->set_node(1);
    }

    return;
} # }}}

sub _xml_attach_array { # {{{
    my ( $xml, $data ) = @_;

    my $i = 0;
    foreach my $item (@{ $data }) {
        if (ref $item eq 'HASH') {
            $xml->[$i] = {};

            _xml_attach_hash($xml->[$i], $item);
        }
        elsif (ref $item eq 'ARRAY') {
            $xml->[$i] = [];

            _xml_attach_array($xml->[$i], $item);
        }
        else {
            $xml->[$i] = $item;
        }

        $xml->[$i]->set_node(1);

        $i++;
    }

    return;
} # }}}

sub _xml_strip_content { # {{{
    my ( $stuff ) = @_;
    
    if (ref $stuff eq 'ARRAY') {
        my @good_stuff;

        foreach my $item (@{ $stuff }) {
            push @good_stuff, _xml_strip_content($item);
        }

        return \@good_stuff;
    }
    elsif (ref $stuff eq 'HASH') {
        if ( (scalar keys %{ $stuff }) == 1 and defined $stuff->{'CONTENT'}) {
            return $stuff->{'CONTENT'};
        }
        else {
            # Strip not needed junk (it SHOULD be just a junk...)
            delete $stuff->{'CONTENT'};

            my %good_stuff;
            foreach my $key (keys %{ $stuff }) {
                $good_stuff{$key} = _xml_strip_content($stuff->{$key});
            }

            return \%good_stuff;
        }
    }

    return $stuff;
} # }}}


sub handle_cms_list { # {{{
    my ( $options ) = @_;

    $options->{'cms-get'} =~ s{^/}{}s;
    $options->{'cms-get'} =~ s{/$}{}s;

    my $path = [ split qr{\/}s, $options->{'cms-get'} ];

    my $page_id = get_Page_id_for_path( $path );

    my $sub_pages = get_Pages_where(
        parent_id => $page_id,
    );

    push_data(
        {
            Head => {
                version => q{0.1},
                status  => 'OK',
            },
            Body => {
                Page => $sub_pages,
            },
        }
    );

    return;
} # }}}

sub handle_cms_get { # {{{
    my ( $options ) = @_;

    $options->{'cms-get'} =~ s{^/}{}s;
    $options->{'cms-get'} =~ s{/$}{}s;

    my $path = [ split qr{\/}s, $options->{'cms-list'} ];

    my $page_id = get_Page_id_for_path( $path );

    my $list = get_Contents_where(
        Page_Entity_id => $page_id,
    );

    my %contents;

    # Add Page entity to the output as well.
    my $page = get_Page($page_id);

    # Sanitize page data.
    if (not $page->{'path'}) {
        $page->{'path'} = q{/};
    }
    if (not $page->{'parent_id'}) {
        $page->{'parent_id'} = 0;
    }
    $contents{'Page'} = [ $page ];

    # Process Content entities on the Page.
    my %Content_Spec_cache;
    my %id_to_class_cache;
    foreach my $item (@{ $list }) {
        my $Content_Spec_id = $item->{'Spec.id'};

        # Harvest Content_Spec
        if (not $Content_Spec_cache{$Content_Spec_id}) {
            $Content_Spec_cache{$Content_Spec_id} = get_ContentSpec($Content_Spec_id);

            $Content_Spec_cache{$Content_Spec_id}->{'Data'} = delete $Content_Spec_cache{$Content_Spec_id}->{'_data'};

            push @{ $contents{'Content_Spec'} }, $Content_Spec_cache{$Content_Spec_id};

            foreach my $class (keys %{ $Content_Spec_cache{$Content_Spec_id}->{'Data'} }) {
                $id_to_class_cache{$Content_Spec_id}->{ $Content_Spec_cache{$Content_Spec_id}->{'Data'}->{$class}->{'id'} } = $class;
            }
        }

        # Sanitize data
        if ($item->{'Data'}) {
            foreach my $lang (keys %{ $item->{'Data'} }) {
                my @ids = keys %{ $item->{'Data'}->{$lang} };

                foreach my $field_id (@ids) {
                    my $field_code = $id_to_class_cache{ $item->{'Spec.id'} }->{$field_id};

                    my $ddata = decode_data(
                        type   => $Content_Spec_cache{$Content_Spec_id}->{'Data'}->{$field_code}->{'datatype'},
                        value  => $item->{'Data'}->{$lang}->{$field_id}->{'value'},
                        target => 'FORM',
                    );
                    delete $item->{'Data'}->{$lang}->{$field_id}->{'value'};

                    $item->{'Data'}->{$lang}->{ $field_code } = $ddata;
                }
            }
        }

        push @{ $contents{'Content'} }, $item;
    }

    push_data(
        {
            Head => {
                version => q{0.1},
                status  => 'OK',
            },
            Body => \%contents,
        }
    );

    return;
} # }}}

sub handle_cms_delete { # {{{
    my ( $options ) = @_;

    $options->{'cms-get'} =~ s{^/}{}s;
    $options->{'cms-get'} =~ s{/$}{}s;

    my $path = [ split qr{\/}s, $options->{'cms-delete'} ];

    my $page_id = get_Page_id_for_path( $path );

    delete_Page($page_id);

    push_data(
        {
            Head => {
                version => q{0.1},
                status  => 'OK',
            },
        }
    );

    return;
} # }}}

# How this works...
#
# First, check if there is a page under the path.
#   If not
#       - Create the page.
#           (id will be ignored, if given, possible 'fixme')
#       - Add Content items to the page.
#           (ids will be ignored, if given, possible 'fixme')
#   If so:
#       - Update the page.
#       - Have any Content entities been supplied?
#           If so
#               - Add ones that are missing
#               - Update (if IDs ware given)
#               - Delete old Contents, that ware not present in the query
#           - Add Content entities to the Page
#
sub handle_cms_set { # {{{
    my ( $options ) = @_;

    $options->{'cms-set'} =~ s{^/}{}s;
    $options->{'cms-set'} =~ s{/$}{}s;

    my $path = [ split qr{\/}s, $options->{'cms-set'} ];

    my $data = pull_data();

#    use Data::Dumper; warn "Path: " . Dumper $path;
#    use Data::Dumper; warn "Pulled data: " . Dumper $data;

    my $page_id = get_Page_id_for_path( $path );

#    warn 'Page_id from path: ' . ($page_id or q{---});

    # If User provided Page data, process this data.
    if ($data->{'Body'}->{'Page'}) {
        if (ref $data->{'Body'}->{'Page'} ne 'ARRAY') {
            $data->{'Body'}->{'Page'} = [
                $data->{'Body'}->{'Page'}
            ];
        }

#        use Data::Dumper; warn 'Page '. Dumper $data->{'Body'}->{'Page'};

        if (not $page_id) {
            # There is no such page, create it.
            # Get it's parent.
            my $new_path_elem = pop @{ $path };

            my $parent_id = get_Page_id_for_path( $path );

            $page_id = add_Page(
                parent_id => $parent_id,
                path      => $new_path_elem,

                template => $data->{'Body'}->{'Page'}->[0]->{'template'},
            );
        }
        else {
            # Page exists, so update it.
            update_Page(
                id => $page_id,

                template => $data->{'Body'}->{'Page'}->[0]->{'template'},
            );
        }
    }

    if ($data->{'Body'}->{'Content'}) {
#       warn "Will update content!";

        if (ref $data->{'Body'}->{'Content'} ne 'ARRAY') {
            $data->{'Body'}->{'Content'} = [
                $data->{'Body'}->{'Content'}
            ];
        }

#        use Data::Dumper; warn 'Page '. Dumper $data->{'Body'}->{'Content'};

        # Get Content present on the selected page.
        my $content_list = get_Contents_where(
            Page_Entity_id => $page_id,
        );

        my %present_content;
        foreach my $Content_Entry (@{ $content_list }) {
            $present_content{ $Content_Entry->{'id'} } = $Content_Entry;
        }

#        warn "I have found this content in DB: ". Dumper \%present_content;

        # FIXME! Encode data!

        foreach my $Content_Entry (@{ $data->{'Body'}->{'Content'} }) {
            my $id = delete $Content_Entry->{'id'};

            # Fix 'Data' key name.
            if ($Content_Entry->{'Data'}) {

                # Fix _data IDs.
                my $Content_Spec = get_ContentSpec($Content_Entry->{'Content_Spec_id'});

                foreach my $lang (keys %{ $Content_Entry->{'Data'} }) {
                    my @fields = keys %{ $Content_Entry->{'Data'}->{$lang} };

                    foreach my $field (@fields) {
                        my $field_id = $Content_Spec->{'_data'}->{$field}->{'id'};

                        $Content_Entry->{'Data'}->{$lang}->{$field_id}->{'value'} = delete $Content_Entry->{'Data'}->{$lang}->{$field};
                    }
                }

#                use Data::Dumper; warn Dumper $Content_Spec;
            }

            if ($id and $present_content{$id}) {
                update_Content(
                    %{ $Content_Entry },

                    id => $id,
                );

#                warn "Updating content!";

                delete $present_content{$id};
            }
            else {
                # FIXME: Check, that this key was empty.
                delete $Content_Entry->{'Page_Entity_id'};

#                warn "Adding content to $page_id!";

                add_Content(
                    'Page_Entity_id' => $page_id,

                    %{ $Content_Entry },
                );
            }
        }

        delete_Contents( [ keys %present_content ] );
    }

    push_data(
        {
            Head => {
                version => q{0.1},
                status  => 'OK',
            },
        }
    );

    return;
} # }}}

# vim: fdm=marker
1;
