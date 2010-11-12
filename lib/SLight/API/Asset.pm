package SLight::API::Asset;
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

use SLight::Core::IO qw( slurp_pipe );
use SLight::Core::Config;
use SLight::Core::DB;

use Carp::Assert::More qw( assert_defined assert_positive_integer );
use Encode qw( encode_utf8 );
use Params::Validate qw( :all );
use File::Slurp;
# }}}

our @EXPORT_OK = qw(
	add_Asset
    attach_Asset_to_Content
    attach_Asset_to_Content_Field
    get_Asset_ids_where
    get_Asset_ids_on_Content
    get_Asset_ids_on_Content_Field
    get_Asset_ids_on_Content_Fields
    get_Asset
    get_Assets
    get_Asset_data
    get_Asset_thumb
    delete_Asset
    delete_Assets
);
our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

my $_handler = SLight::Core::Entity->new( # {{{
    base_table  => 'Asset_Entity',

    data_fields => [qw( filename byte_size mime_type summary )],

    has_owner => 1,
); # }}}

# Parameters:
#   data : binary data, that should be stored on server's hard drive.
sub add_Asset { # {{{
    my %P = validate(
        @_,
        {
            data => { type=>SCALAR },

            email => { type=>SCALAR },

            filename => { type=>SCALAR },
            summary  => { type=>SCALAR, optional=>1, default=>q{} },
        }
    );

    my $binary_data = delete $P{'data'};
    
    my $id = $_handler->add_ENTITY(
        'email'    => $P{'email'},
        'summary'  => $P{'summary'},
        'filename' => $P{'filename'},
    );

    my $path = _path_for_id($id);

    # Note to self: (fixme, later)
    #   put the file on temp space,
    #   process it there,
    #   then add stuff to DB and
    #   THEN move the file to it's final destination.
    write_file($path, $binary_data);

    my $mime_type = ( slurp_pipe('file -ib '. $path), or 'unknown' );
    chomp $mime_type;

    # Remove 'charset' part. We do not use it. It MAY be useful later.
    $mime_type =~ s{; charset.*$}{}s;

    # Update metadata.
    $_handler->update_ENTITY(
        'id' => $id,

        'byte_size' => ( -s $path ),
        'mime_type' => $mime_type,
    );

    # If this file is supported - try to make a thumbnail.
    my %thumbnailers = (
        'image/jpeg' => \&_image_thumbnailer,
        'image/gif'  => \&_image_thumbnailer,
        'image/png'  => \&_image_thumbnailer,
    );
    if ($thumbnailers{ $mime_type }) {
        $thumbnailers{ $mime_type }->($path);
    }

    return $id;
} # }}}

sub attach_Asset_to_Content { # {{{
    my ( $Asset_id, $Content_Entity_id ) = @_;

    return SLight::Core::DB::run_insert(
        'into'   => 'Asset_2_Content',
        'values' => {
            Asset_Entity_id   => $Asset_id,
            Content_Entity_id => $Content_Entity_id,
        },
    );
} # }}}

sub attach_Asset_to_Content_Field { # {{{
    my ( $Asset_id, $Content_Entity_id, $Content_Spec_Field_id ) = @_;

    return SLight::Core::DB::run_insert(
        'into'   => 'Asset_2_Content_Field',
        'values' => {
            Asset_Entity_id       => $Asset_id,
            Content_Entity_id     => $Content_Entity_id,
            Content_Spec_Field_id => $Content_Spec_Field_id,
        },
    );
} # }}}

# Add other attach_Asset_to_... as needed.

# Purpose:
#   Return Asset IDs, attached directly to Content (so not Content+Field).
sub get_Asset_ids_on_Content { # {{{
    my ( $Content_Entry_id ) = @_;

    my $sth = SLight::Core::DB::run_query(
        query => [ 'SELECT Asset_Entity_id FROM Asset_2_Content WHERE Content_Entity_id = ', $Content_Entry_id ],
    );

    return _slurp_ids($sth);
} # }}}

sub get_Asset_ids_on_Content_Field { # {{{
    my ( $Content_Entry_id, $Content_Spec_Field_id ) = @_;

    my $sth = SLight::Core::DB::run_query(
        query => [ 'SELECT Asset_Entity_id FROM Asset_2_Content_Field WHERE Content_Entity_id = ', $Content_Entry_id, ' AND Content_Spec_Field_id = ', $Content_Spec_Field_id ],
    );

    return _slurp_ids($sth);
} # }}}

sub get_Asset_ids_on_Content_Fields { # {{{
    my ( $Content_Entry_id ) = @_;
    
    my $sth = SLight::Core::DB::run_query(
        query => [ 'SELECT Asset_Entity_id FROM Asset_2_Content_Field WHERE Content_Entity_id = ', $Content_Entry_id ],
    );

    return _slurp_ids($sth);
} # }}}

sub _slurp_ids { # {{{
    my ( $sth ) = @_;

    my @ids;
    while (my ($id) = $sth->fetchrow_array()) {
        push @ids, $id;
    }

    return \@ids;
} # }}}

# Return metadata for one, selected Asset.
sub get_Asset { # {{{
    my ( $id ) = @_;

    my $asset = $_handler->get_ENTITY($id);

    if (not $asset) {
        return;
    }

    $asset->{'path'}  = _path_for_id($asset->{'id'});
    $asset->{'thumb'} = _thumb_path($asset->{'path'});

    return $asset;
} # }}}

sub get_Assets { # {{{
    my ( $ids ) = @_;

    my $assets = $_handler->get_ENTITYs($ids);

    foreach my $asset (@{ $assets }) {
        _fix_asset($asset);
    }

    return $assets;
} # }}}

sub get_Asset_data { # {{{
    my ( $id ) = @_;

    assert_positive_integer($id, 'id makes sense');

    return read_file(_path_for_id($id));
} # }}}

sub get_Asset_thumb { # {{{
    my ( $id ) = @_;

    assert_positive_integer($id, 'id makes sense');

    return read_file(_thumb_path(_path_for_id($id)));
} # }}}

sub get_Asset_ids_where { # {{{
    my %P = @_;

    return $_handler->get_ENTITY_ids_where(%P);
} # }}}

sub delete_Asset { # {{{
    my ( $id ) = @_;

    assert_defined($id, 'ID is defined');

    my $asset = $_handler->get_ENTITY($id);
    if (not $asset) {
        return;
    }

    _fix_asset($asset);

    unlink $asset->{'path'};
    unlink $asset->{'thumb'};

    $_handler->delete_ENTITY($id);

    return;
} # }}}

sub delete_Assets { # {{{
    my ( $ids ) = @_;
    
    my $assets = $_handler->get_ENTITYs($ids);
    foreach my $asset (@{ $assets }) {
        _fix_asset($asset);

        unlink $asset->{'path'};
        unlink $asset->{'thumb'};
    }

    $_handler->delete_ENTITYs($ids);

    return;
} # }}}

# Utility functions.

sub _fix_asset { # {{{
    my ( $asset ) = @_;

    $asset->{'path'}  = _path_for_id($asset->{'id'});
    $asset->{'thumb'} = _thumb_path($asset->{'path'});

    return $asset;
} # }}}

sub _path_for_id { # {{{
    my ( $id ) = @_;

    assert_defined($id, "ID defined");

    my $sub_dir = sprintf "%02d", ( substr $id, -2 );

    my $path = SLight::Core::Config::get_option('data_root') . q{assets/} . $sub_dir;

    if (not -d $path) {
        mkdir $path;
    }

    $path .= q{/}. $id .q{.bin};

    return $path;
} # }}}

sub _thumb_path { # {{{
    my ( $path ) = @_;

    my $thumb = $path;
    $thumb =~ s{\.bin$}{-thumb.png}s;

    return $thumb;
} # }}}

# Thumbnailers

sub _image_thumbnailer { # {{{
    my ( $source ) = @_;

    my $destination = _thumb_path($source);

    slurp_pipe( 'convert -geometry 128x128 ' . $source .q{ }. $destination );

    return $destination;
} # }}}

# vim: fdm=marker
1;
