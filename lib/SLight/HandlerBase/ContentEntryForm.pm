package SLight::HandlerBase::ContentEntryForm;
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

use SLight::Core::L10N qw( TR TF );
use SLight::API::Util qw( human_readable_size );
use SLight::API::Asset qw( attach_Asset_to_Content_Field get_Asset_ids_on_Content_Field get_Asset delete_Assets );
use SLight::DataType;
use SLight::Validator qw( validate_input );

use Params::Validate qw( :all );
# }}}

# Fixme:
#   Change package to SLight::HandlerBase::CMS::EntryForm

my %signatures_cache;
    
sub build_form_guts { # {{{
    my (  $self, %P ) = @_;

    my $spec = $P{'spec'};
    my $form = $P{'form'};

    my $page    = $P{'page'};
    my $content = $P{'content'};

    my $lang = $self->{'url'}->{'lang'};

    # Add the caption, so User knows what kind of data it enters.
    $form->add_Label(
        text => $spec->{'caption'}
    );

    # Used by 'AddContent' variant.
    if ($self->{'options'}->{'target'} and $self->{'options'}->{'target'} eq 'New') {
        # Add metadata required for the entry to be created.
        $form->add_Entry(
            caption => TR('Path element name'),
            name    => 'page.path',
            value   => ( $self->{'options'}->{'page.path'} or $page->{'path'} or q{}),
            error   => $P{'errors'}->{'meta.path'},
        );
        # Fixme! This should be a select entry!
        $form->add_Entry(
            caption => TR('Template file'),
            name    => 'page.template',
            value   => ( $self->{'options'}->{'page.template'} or $page->{'template'} or q{}),
            error   => $P{'errors'}->{'page.template'},
        );
    }

    # Content must be signed, so if current User has not logged-in,
    # he must provide an email address, that will be used to sign this new entry.
    # Note/limitation:
    #   once created, this field can not be changed.
    if (not $content and not $self->{'params'}->{'user'}->{'email'} and not $content->{'Email_id'}) {
        $form->add_Entry(
            caption => TR('Email (internal use only)'),
            name    => 'meta.email',
            value   => ( $self->{'options'}->{'meta.email'} or q{} ),
            error   => $P{'errors'}->{'meta.email'},
        );
    }

#    use Data::Dumper; warn Dumper $ContentData;

#    use Data::Dumper; warn Dumper $P{'errors'};

    # Add data fields from ContentType.
    foreach my $field_name (@{ $spec->{'_data_order'} }) {
        my $field = $spec->{'_data'}->{$field_name};

        $self->_add_field_to_form(
            content => $content,
            errors  => $P{'errors'},

            field_name => $field_name,
            field_spec => $field,

            form => $form
        );
    }

    # Fixme: there should be a system-wide, config-based default option for comments.
    $form->add_SelectEntry(
        caption => TR('Comment write policy'),
        name    => 'meta.comment_write_policy',
        value   => ( $self->{'options'}->{'meta.comment_write_policy'} or $content->{'comment_write_policy'} or 0),
        error   => $P{'errors'}->{'meta.comment_write_policy'},
        options => [
            [ 0, TR(q{Disabled}) ],
            [ 1, TR(q{By registered users only (moderated)}) ],
            [ 2, TR(q{By registered users only}) ],
            [ 3, TR(q{By all users (moderated)}) ],
            [ 4, TR(q{By all users}) ],
        ]
    );
    $form->add_SelectEntry(
        caption => TR('Comment display policy'),
        name    => 'meta.comment_read_policy',
        value   => ( $self->{'options'}->{'meta.comment_read_policy'} or $content->{'comment_read_policy'} or 0),
        error   => $P{'errors'}->{'meta.comment_read_policy'},
        options => [
            [ 0, TR(q{Comments are hidden}) ],
            [ 1, TR(q{Visible to registered users only}) ],
            [ 2, TR(q{Visible to everyone}) ],
        ]
    );

    return;
} # }}}

# Map DataType to form field type.
my %type_map = (
    String => 'add_Entry',
    Text   => 'add_TextEntry',
);

# Add single field to Content Entry Form response.
sub _add_field_to_form { # {{{
    my ( $self, %P ) = @_;

#    my ( $self, $content, $errors, $field_name, $field_spec, $form ) = @_;

    my $field_name = $P{'field_name'};
    my $field_spec = $P{'field_spec'};

    my $signature = (
        $signatures_cache{ $field_spec->{'datatype'} }
    or
        $signatures_cache{ $field_spec->{'datatype'} } = SLight::DataType::signature(type=>$field_spec->{'datatype'})
    );

    # FIXME: no way to select on-page order.

    my $cgi_field_name = q{content.}. $field_name;

    if ($signature->{'asset'}) {
        # This field is handled by an asset.
        # It requires some additional care, as support has to be implemented for:
        #   - showing that asset IS attached.
        #   - adding the possibility to upload new asset
        #   - adding the possibility to remove asset
        # Not entering a file means: no change.
        # Entering file means: use this file.
        # Selecting 'delete asset' will remove the asset (clear the field).
        #
        # System will also provide a way of labeling the asset with some text.
        # This text can then be used as title, or while searching.
        # This text will be stored in the DB, while file is stored in file system.
        $P{'form'}->add_FileEntry(
            name => $cgi_field_name .q{-data},

            caption => $field_spec->{'caption'},
            error   => $P{'errors'}->{ $cgi_field_name .q{-data} },
        );
        $P{'form'}->add_Entry(
            name => $cgi_field_name,

            caption => TR('Summary'),
            value   => ( $self->{'options'}->{$cgi_field_name} or $P{'content'}->{'_data'}->{$field_name} or q{} ),
            error   => $P{'errors'}->{$cgi_field_name},
        );
        if ($P{'content'}->{'id'}) {
            my $asset_ids = get_Asset_ids_on_Content_Field($P{'content'}->{'id'}, $field_spec->{'id'});

            if (scalar @{ $asset_ids }) {
                my $asset_meta = get_Asset($asset_ids->[0]); # FIXME: display ALL assets (there can be more of them?)

                $P{'form'}->add_Label(
                    text  => TF('Already attached: %s', undef, human_readable_size($asset_meta->{'byte_size'})),
                    class => 'Hint'
                );
                $P{'form'}->add_Check(
                    name => $cgi_field_name . q{-remove},
    
                    caption => TR('Remove attachment'),
                    checked => 0,
                );
            }
        }
    }
    else {
        my $method = $type_map{ $signature->{'entry'} };

        my ( $field_lang, $lang_info );
        if ($field_spec->{'translate'}) {
            $field_lang = $self->{'url'}->{'lang'};
            $lang_info  = $self->{'url'}->{'lang'};
        }
        else {
            $field_lang = q{*};
            $lang_info  = TR("any language");
        }

        # Value may come from various sources:
        my $entry_value = q{};
        if ($self->{'options'}->{$cgi_field_name}) {
            # Value will be initialized from CGI data.
            $entry_value = $self->{'options'}->{$cgi_field_name};
        }
        else {
            # Value will be initialized from DB data.
            $entry_value = SLight::DataType::decode_data(
                type   => $field_spec->{'datatype'},
                value  => ( $P{'content'}->{'_data'}->{$field_lang}->{$field_spec->{'id'}} or q{} ),
                format => q{},
                target => 'FORM',
            );
        }

        $P{'form'}->$method(
            name => $cgi_field_name,

            caption => ( sprintf "%s (%s)", $field_spec->{'caption'}, $lang_info ),
            value   => ( $entry_value or q{} ),
            error   => $P{'errors'}->{$cgi_field_name},
        );
    }

    return;
} # }}}

# Slurp data given to Request, validate it and prepare for saving.
#
# If data fails validation, either %errors, %warnings or both will contain information to the User.
# In this case, %data and %assets will be empty.
#
# If data passed trough validation, but there are things to consider - %warnings will contain them.
# In this case %errors will be empty, %data and %assets will be filled.
# Data, that triggers warnings, may be stored in DB.
#
# If everything is OK, then %errors and %warnings will be empty, %data and %assets will be filled.
sub slurp_content_form_data { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            content      => { type=>HASHREF, optional=>1, },
            content_spec => { type=>HASHREF },
        }
    );

    # Do validation.
    my $errors = validate_input(
        $self->{'options'},
        $self->mk_validator_metadata(%P)
    );

#    use Data::Dumper; warn Dumper $errors;

    # If there are any errors, stop processing and return them.
    if ($errors) {
        return ($errors, {}, {}, {});
    }

    my %warnings;
    my %data;
    my %assets;

    # If there are no errors, process Entry fields.
    foreach my $field_name (keys %{ $P{'content_spec'}->{'_data'} }) {
        my $cgi_name = q{content.}. $field_name;

        my $field_spec = $P{'content_spec'}->{'_data'}->{$field_name};

        # Signature should already be in cache (from previous foreach).
        if ($signatures_cache{ $field_spec->{'datatype'} }->{'asset'}) {
            # This is an asset-based field.
            # Warning: special handling ahead ;)
            my $field_id = $P{'content_spec'}->{'_data'}->{$field_name}->{'id'};

            $assets{ $field_id } = {
                filename => ( $self->{'options'}->{ $cgi_name .q{-filename} } or q{Unknown} ),
                summary  => ( $self->{'options'}->{ $cgi_name               } or q{} ),
                data     => ( $self->{'options'}->{ $cgi_name .q{-data}     } or q{} ),
                remove   => ( $self->{'options'}->{ $cgi_name .q{-remove}   } or 0 ),
            };
        }

        my $field_lang = q{*};
        if ($field_spec->{'translate'}) {
            $field_lang = $self->{'url'}->{'lang'};
        }

        $data{ $field_lang }->{ $field_spec->{'id'} } = SLight::DataType::encode_data(
            type  => $field_spec->{'datatype'},
            value => ( $self->{'options'}->{$cgi_name} or q{} )
        );
    }

#    use Data::Dumper; warn "Data slurped from form: ". Dumper \%data;
#    use Data::Dumper; warn Dumper \%errors;

    return ( $errors, \%warnings, \%data, \%assets );
} # }}}

sub mk_validator_metadata { # {{{
    my ( $self, %P ) = @_;
    
    # Prepare validation metadata.
    my %validator_metadata = (
        'meta.comment_write_policy' => { type=>'Integer' },
        'meta.comment_read_policy'  => { type=>'Integer' },
    );

    if ($self->{'options'}->{'target'} and $self->{'options'}->{'target'} eq 'New') {
        $validator_metadata{'page.path'}     = { type=>'FileName' };
        $validator_metadata{'page.template'} = { type=>'FileName', optional=>1, };
    }

    if (not $P{'content'} and not $self->{'user'}->{'email'}) {
        $validator_metadata{'meta.email'} = { type=>'Email', max_length=>1024 };
    }

#    use Data::Dumper; warn Dumper \%validator_metadata;

    foreach my $field_name (keys %{ $P{'content_spec'}->{'_data'} }) {
        my $field = $P{'content_spec'}->{'_data'}->{$field_name};

        my $cgi_name = q{content.}. $field_name;

        my $signature = ( $signatures_cache{ $field->{'datatype'} } or $signatures_cache{ $field->{'datatype'} } = SLight::DataType::signature(type=>$field->{'datatype'}) );

        if ($signature->{'asset'}) {
            # Asset fields require some special handling.
            $validator_metadata{$cgi_name} = {
                type       => 'String',
                optional   => 1,
                max_length => 512,
            };
            $validator_metadata{$cgi_name .'-data'} = {
                type       => 'Any',
                optional   => ( $field->{'optional'}   or 1 ),
                max_length => ( $field->{'max_length'} or 1024 ),
            };
        }
        else {
            $validator_metadata{$cgi_name} = {
                type       => ( $signature->{'validator_type'} or 'Any' ),
                optional   => ( $field->{'optional'}   or 1 ),
                max_length => ( $field->{'max_length'} or 1024 ),
            };
        }
    }

    return \%validator_metadata;
} # }}}

sub process_field_assets { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            id     => { type=>SCALAR },
            assets => { type=>HASHREF },
        }
    );

    foreach my $field_id (keys %{ $P{'assets'} }) {
        my $form_entry = $P{'assets'}->{ $field_id };

        if ($form_entry->{'data'}) {
            # Asset was sent with form.
            # Check if We already have an Asset attached?
            my $asset_ids = get_Asset_ids_on_Content_Field(
                $P{'id'},
                $field_id,
            );
            if ($asset_ids) {
                # Yes - those must be deleted prior new one can be attached.
                delete_Assets($asset_ids);
            }

            # Put the Asset on HDD :)
            #                           ...or whatever.
            my $asset_id = SLight::API::Asset::add_Asset(
                data => $form_entry->{'data'},

                email => ( $self->{'user'}->{'email'} or $self->{'options'}->{'meta.email'} or q{test@test.test} ), # FIXME!

                filename => $form_entry->{'filename'},
                summary  => $form_entry->{'summary'},
            );
            attach_Asset_to_Content_Field(
                $asset_id,
                $P{'id'},
                $field_id,
            );
        }
    }

    return;
} # }}}

# vim: fdm=marker
1;
