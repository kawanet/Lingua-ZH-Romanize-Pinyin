=head1 NAME

Lingua::ZH::Romanize::DictZH - Dictionary converter

=head1 SYNOPSIS

    perl -MLingua::ZH::Romanize::DictZH -e 'Lingua::ZH::Romanize::DictZH->update();'

=head1 DESCRIPTION

This module creates dictionary cache files for
L<Lingua::ZH::Romanize::Pinyin> module.

Source dictionary files: (included in this package)

    Lingua/ZH/Romanize/big5/CTLauBig5.tit
    Lingua/ZH/Romanize/big5/PY.tit
    Lingua/ZH/Romanize/gb/CTLau.tit
    Lingua/ZH/Romanize/gb/PY.tit

Cached dictionary files:

    Lingua/ZH/Romanize/Cantonese.store
    Lingua/ZH/Romanize/Pinyin.store

DictZH is called only from Makefile.PL in the Pinyin package.

=head1 REQUIRED MODULES

L<Storable> module is required to create cached dictionary files.
Both of L<Unicode::Map> and L<Unicode::String> modules are
required on Perl 5.005 and 5.6.x to install the Pinyin package.
L<Encode> module is used on Perl 5.8.x.

=head1 SEE ALSO

L<Lingua::ZH::Romanize::Pinyin>

=cut

package Lingua::ZH::Romanize::DictZH;
use strict;
use vars qw( $VERSION );
$VERSION = "0.13";

my $USE_ENCODE_PM = ( $] >= 5.008 );    # Perl 5.8.x or not

#   $USE_ENCODE_PM = 1;                 # force to use Encode.pm
#   $USE_ENCODE_PM = 0;                 # force to use Unicode::Map and Unicode::String
#   my $SKIP_IF_EXISTS = 1;             # don't update when .store file exists
my $SKIP_IF_EXISTS = 0;                 # override .store file when it exists

my $DICT_FILES = {
    'Cantonese.store' => [qw(
          cxterm/dict/big5/CTLauBig5.tit
          cxterm/dict/gb/CTLau.tit
    )],
    'Pinyin.store' => [qw(
          cxterm/dict/big5/PY.tit
          cxterm/dict/gb/PY.tit
    )],
};

sub update {
    my $package = shift;
    my $base    = shift;
    unless ( defined $base ) {
        $base = $INC{ join( '/', split( '::', (__PACKAGE__) . '.pm' ) ) };
        $base =~ s#/[^/]*$##;
    }

    my $update = 0;
    foreach my $storename ( keys %$DICT_FILES ) {
        my $storepath = $base . '/' . $storename;
        if ( -r $storepath ) {
            warn "Already-Exist: $storepath\n";
        }
        else {
            $update++;
        }
    }
    return if ( $SKIP_IF_EXISTS && !$update );    # no need to update

    warn "Loading-Module: Storable.pm\n";
    &require_storable();                          # required

    if ($USE_ENCODE_PM) {
        warn "Loading-Module: Encode.pm\n";
        &require_encode();                        # Perl 5.8.x
    }
    else {
        warn "Loading-Module: Unicode::Map\n";
        &require_unicode_map();                   # Perl 5.005/5.6.x
        warn "Loading-Module: Unicode::String\n";
        &require_unicode_string();                #
    }

    foreach my $storename ( keys %$DICT_FILES ) {
        my $hash = {};
        foreach my $titpath ( @{ $DICT_FILES->{$storename} } ) {
            warn "Loading-Dictionary: $titpath\n";
            $hash = &read_tit_dict( $titpath, $hash );
        }
        foreach my $key ( keys %$hash ) {
            next unless ref $hash->{$key};
            my $list = $hash->{$key};
            my $uniq = { map { $_ => 1 } @$list };
            foreach my $chk ( @$list ) {
                next unless ( $chk =~ s/[0-9]+$// );
                delete $uniq->{$chk} if exists $uniq->{$chk};
            }
            $hash->{$key} = join( '/', sort keys %$uniq );
        }
        my $storepath = $base . '/' . $storename;
        warn "Writing-Storable: $storepath\n";
        Storable::store( $hash, $storepath ) or die "$! - $storename\n";
    }

    undef;
}

sub read_tit_dict {
    my $titname = shift or return;
    my $hash   = shift || {};
    my $cmap   = {qw( GB GB2312 BIG5 BIG5 KS EUC-KR JIS EUC-JP )};
    my $unistr = Unicode::String->new() unless $USE_ENCODE_PM;

    # find ENCODE: and wait until BEGINDICTIONARY
    open( TIT, $titname ) or die "$! - $titname\n";
    my $code;
    while (<TIT>) {
        next if /^#/;
        $code = $cmap->{ uc($1) } if (/^ENCODE:\s*(\S+)/);
        last if /^BEGINDICTIONARY/;
    }
    warn "Dictionary-Encoding: $code\n" if $code;
    my $unimap = Unicode::Map->new($code) unless $USE_ENCODE_PM;

    while ( my $line = <TIT> ) {
        next if ( $line =~ /^#/ );
        chomp $line;

        my ( $roman, $kanji ) = split( /\s+/, $line, 2 );
        $roman =~ s/^\\[0-7]{3}//s;
#       $roman =~ s/\d+$//s;

        # convert encoding from GB/BIG5 to UTF-8
        if ($code) {
            if ($USE_ENCODE_PM) {
                Encode::from_to( $kanji, $code, 'UTF-8' );    # GB/BIG5 to UTF-8
            }
            else {
                my $utf16 = $unimap->to_unicode($kanji);      # GB/BIG5 to UCS2
                $unistr->ucs2($utf16);
                $kanji = $unistr->utf8();                     # UCS2 to UTF-8
            }
        }

        # split every UTF-8 wide characters
        while ( $kanji =~ /([\300-\377][\200-\277]+)/g ) {
            my $char = $1;
            if ( !exists $hash->{$char} ) {
                $hash->{$char} = $roman;
            }
            elsif ( !ref $hash->{$char} ) {
                $hash->{$char} = [ $hash->{$char}, $roman ];
            }
            else {
                push( @{ $hash->{$char} }, $roman );
            }
        }
    }
    close(TIT);

    $hash;
}

sub require_storable {
    return if defined $Storable::VERSION;
    local $@;
    eval { require Storable; };
    die "Storable module is required.\n" if $@;
}

sub require_encode {
    return if defined $Encode::VERSION;
    local $@;
    eval { require Encode; };
    die "Encode module is required.\n" if $@;
}

sub require_unicode_string {
    return if defined $Unicode::String::VERSION;
    local $@;
    eval { require Unicode::String; };
    die "Unicode::String module is required.\n" if $@;
}

sub require_unicode_map {
    return if defined $Unicode::Map::VERSION;
    local $@;
    eval { require Unicode::Map; };
    die "Unicode::Map module is required.\n" if $@;
}

1;
