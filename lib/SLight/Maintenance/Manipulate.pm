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

my $VERSION = '0.0.3';

use SLight::API::Content qw( get_Contents_where );
use SLight::API::Page qw( get_Page get_Page_id_for_path );
use SLight::Core::Config;
use SLight::Core::DB;

use Cwd qw( getcwd );
use English qw( -no_match_vars );
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
        'cms-delete' => q{},
        'cms-set'    => q{},
    );
    
    if (not scalar @params) {
        push @params, q{--help};
    }

    GetOptionsFromArray(
        \@params,

        'cms-list=s'   => \$options{'cms-list'},
        'cms-delete=s' => \$options{'cms-delete'},
        'cms-set=s'    => \$options{'cms-set'},
        
        'format' => \$options{'format'},
        'input'  => \$options{'input'},
        'output' => \$options{'output'},

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
        print "  --cms-list /Path/   List CMS Entities on page /Path/\n";
        print "  --cms-set /Path/    Set CMS Entity on page /Path/ (requires data input)\n";
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

        return JSON::XS::Load($raw_data);
    }
    if ($_format eq 'xml') {
        require XML::Simple;

        return XML::Simple::XMLIn($raw_data);
    }

    # Unsupported data format :(

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

        $string = JSON::XS::Dump($data);
    }
    elsif ($_format eq 'xml') {
        require XML::Simple;

        $string = XML::Simple::XMLOut($data);
    }

    # Step two - either print, or write to a file.
    if ($_output eq q{-}) {
        # Read from STDIN.
        print $string;
    }
    else {
        write_file($_output, $string);
    }

    return;
} # }}}



sub handle_cms_list { # {{{
    my ( $options ) = @_;

    
    $options->{'cms-list'} =~ s{^/}{}s;
    $options->{'cms-list'} =~ s{/$}{}s;

    my $path = [ split qr{\/}s, $options->{'cms-list'} ];

    use Data::Dumper; warn "Path: ". Dumper $path;

    my $page_id = get_Page_id_for_path( $path );

    warn $page_id;

    my $list = get_Contents_where(
        Page_Entity_id => $page_id,
    );

    push_data($list);

    return;
} # }}}

sub handle_cms_delete { # {{{
    my ( $options ) = @_;

    return;
} # }}}

sub handle_cms_set { # {{{
    my ( $options ) = @_;

    return;
} # }}}

# vim: fdm=marker
1;
