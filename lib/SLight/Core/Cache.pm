package SLight::Core::Cache;
use strict; use warnings; # {{{
use base 'Exporter';
our @EXPORT_OK = qw(
    Cache_begin_L1
    Cache_end_L1

    Cache_get
    Cache_get_L1

    Cache_put
    Cache_put_L1

    Cache_invalidate
    Cache_invalidate_referenced
    
    Cache_read_file
    Cache_read_yaml
);
our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);

$YAML::Syck::ImplicitUnicode = 1; ## no critic qw(ProhibitPackageVars)

use Digest::MD5 qw( md5_hex );
use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use File::Slurp qw( read_file );
use Params::Validate qw( :all );
use YAML::Syck qw( LoadFile DumpFile );
# }}}

# Notes:
#   Namespace should be dervied from the module's (package) class.
#   Doing it this way should remove much of the risk asociated 
#   with namespace colisions.

# Level 1 cache variables:
my $L1_cache = {};
my $L1_enabled = 0;

# File cache variables:
#my %cached_files;
#my %cached_yaml;

my $HIT_MISS_DEBUG = 0;

# Purpose:
#   Signal cache facility, that L1 cache should be enabled.
#   Additionally, L1 cache is purged.
sub Cache_begin_L1 { # {{{
    $L1_cache = {};

    return $L1_enabled = 1;
} # }}}

# Purpose:
#   Signal cache facility, that L1 cache should be disabled.
#   Additionally, L1 cache is purged.
sub Cache_end_L1 { # {{{
    $L1_cache = {};

    return $L1_enabled = 0;
} # }}}


sub Cache_get { # {{{
    my ( $namespace, $key ) = @_;

    my $eval_data = eval {
        if ($L1_enabled) {
            my $data = Cache_get_L1($namespace, $key);

            if ($data) {
                if ($HIT_MISS_DEBUG) { print STDERR "SLight::Core::Cache L1 HIT ($key)\n"; }

                return $data;
            }
        }

        my $path = _build_path($namespace, $key);

        if (-e $path) {
            if ($HIT_MISS_DEBUG) { print STDERR "SLight::Core::Cache L2 HIT ($key) $path\n"; }

            return LoadFile($path);
        }

        if ($HIT_MISS_DEBUG) { print STDERR "SLight::Core::Cache L2 MISS ($key) $path\n"; }

        return;
    };
    if (not $eval_data and $EVAL_ERROR) {
        print STDERR "SLight::Core::Cache::Cache_invalidate ERROR: ". $EVAL_ERROR;
    }

    return $eval_data;
} # }}}

sub Cache_get_L1 { # {{{
    my ( $namespace, $key ) = @_;

    if ($L1_enabled) {
        return $L1_cache->{$namespace}->{$key};
    }
    
    return;
} # }}}


sub Cache_put { # {{{
    my ( $namespace, $key, $value, $references ) = @_;

    assert_defined($value, "Value is defined"); # Use invalidate to delete items from cache!

    my $eval_value = eval {
        if ($L1_enabled) {
            Cache_put_L1($namespace, $key, $value);
        }

        my $path = _build_path($namespace, $key, 1);

        if ($references) {
            _put_references($namespace, $key, $references);
        }

        if ($HIT_MISS_DEBUG) { print STDERR "SLight::Core::Cache L2 PUT ($key) $path\n"; }

        # No need to make it safe, I guess, as that would only make things longer.
        # This is not vital data. Right?
        DumpFile($path, $value);

        return $value;
    };

    if (not $eval_value) {
        print STDERR "SLight::Core::Cache::Cache_invalidate ERROR: ". $EVAL_ERROR;
    }

    return $eval_value;
} # }}}

sub Cache_put_L1 { # {{{
    my ( $namespace, $key, $value ) = @_;

    assert_defined($value, "Value is defined"); # Use invalidate to delete items from cache.

    if ($L1_enabled) {
        $L1_cache->{$namespace}->{$key} = $value;
        
        return $value;
    }

    return;
} # }}}

# Purpose:
#   Invalidate selected Cache entry.
sub Cache_invalidate { # {{{
    my ( $namespace, $key ) = @_;

    my $ok = eval {
        if (exists $L1_cache->{$namespace}->{$key}) {
            delete $L1_cache->{$namespace}->{$key};
        }

        my $path = _build_path($namespace, $key);

        if ($path and -e $path) {
            unlink $path;
        }

        return 1;
    };
    if (not $ok) {
        print STDERR "SLight::Core::Cache::Cache_invalidate ERROR: ". $EVAL_ERROR;
    }

    return $ok;
} # }}}

# Purpose:
#   Invalidate all Cache entries, that refer/contain mentioned IDs.
sub Cache_invalidate_referenced { # {{{
    my ( $namespace, $referenced ) = @_;

    # Find, which cache items refer to given objects.
    my $sth = SLight::Core::DB::run_query(
        query => [ "SELECT key FROM  Cache_Reference WHERE namespace = ", $namespace, " AND id IN ", $referenced ],
        debug => 0,
    );

    # Delete found Cache items.
    my $count = 0;
    while (my ($entry) = $sth->fetchrow_array()) {
        Cache_invalidate($namespace, $entry);

        $count++;
    }
    
    # Reference information can now be deleted.
    SLight::Core::DB::run_query(
        query => [ "DELETE FROM Cache_Reference WHERE namespace = ", $namespace, " AND id IN ", $referenced ],
        debug => 0,
    );

    return $count;
} # }}}

# WIP 
#sub Cache_read_file { # {{{
#    my ( $path ) = @_;
#
#} # }}}

# WIP
#sub Cache_read_yaml { # {{{
#    my ( $path ) = @_;
#
#} # }}}

my $_cache_path;

sub _build_path { # {{{
    my ( $namespace, $key, $make_dir ) = @_;

    if (not $_cache_path) {
        $_cache_path = SLight::Core::Config::get_option('data_root') . q{cache/};
    }
    
    if ($make_dir and not -d $_cache_path . $namespace) {
        mkdir $_cache_path . $namespace;
    }

    my $stamp = md5_hex($key);

    my $entry_sub_dir = $_cache_path . $namespace . q{/} . ( substr $stamp, -2 );

    if ($make_dir and not -d $entry_sub_dir) {
        mkdir $entry_sub_dir;
    }

#    warn "Cache file: ". $entry_sub_dir . q{/} . $stamp;

    return $entry_sub_dir . q{/} . $stamp;
} # }}}

# Purpose:
#   Store information, that will allow to find cache items, that contain or refer to some objects.
sub _put_references { # {{{
    my  ( $namespace, $key, $references ) = @_;

    foreach my $id (@{ $references }) {
        SLight::Core::DB::run_query(
            query => [ "INSERT INTO Cache_Reference (id, namespace, key) VALUES ", [ $id, $namespace, $key ]],
            debug => 0,
        );
    }

    return;
} # }}}

# vim: fdm=marker
1;
