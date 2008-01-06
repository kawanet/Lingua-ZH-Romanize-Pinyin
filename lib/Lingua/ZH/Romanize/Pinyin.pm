=head1 NAME

Lingua::ZH::Romanize::Pinyin - Romanization of Standard Chinese language

=head1 SYNOPSIS

    use Lingua::ZH::Romanize::Pinyin;

    my $conv = Lingua::ZH::Romanize::Pinyin->new();
    my $roman = $conv->char( $hanji );
    printf( "<ruby><rb>%s</rb><rt>%s</rt></ruby>", $hanji, $roman );

    my @array = $conv->string( $string );
    foreach my $pair ( @array ) {
        my( $raw, $ruby ) = @$pair;
        if ( defined $ruby ) {
            printf( "<ruby><rb>%s</rb><rt>%s</rt></ruby>", $raw, $ruby );
        } else {
            print $raw;
        }
    }

=head1 DESCRIPTION

Pinyin is a phonemic notation for Chinese characters.

=head2 $conv = Lingua::ZH::Romanize::Pinyin->new();

This constructer methods returns a new object with its dictionary cached.

=head2 $roman = $conv->char( $hanji );

This method returns romanized letters of a Hanji character.
It returns undef when $hanji is not a valid Hanji character.
The argument's encoding must be UTF-8.
Both of Simplified Chinese and Traditional Chinese are allowed.

=head2 $roman = $conv->chars( $string );

This method returns romanized letters of Hanji characters.

=head2 @array = $conv->string( $string );

This method returns a array of referenced arrays
which are pairs of a Hanji chacater and its romanized letters.

    $array[0]           # first Chinese character's pair (array)
    $array[1][0]        # secound Chinese character itself
    $array[1][1]        # its romanized letters

=head1 DICTIONARY

This module's Hanji to roman mapping table is based on
PY.tit file which is distributed with cxterm.

=head1 MODULE DEPENDENCIES

L<Storable> module is required.

=head1 SEE ALSO

L<Lingua::ZH::Romanize::Cantonese>
L<Lingua::JA::Romanize::Japanese>
L<Lingua::KO::Romanize::Hangul>

http://www.kawa.net/works/perl/romanize/romanize-e.html

=head1 AUTHOR

Yusuke Kawasaki http://www.kawa.net/

=head1 COPYRIGHT

Copyright (c) 2003-2006 Yusuke Kawasaki. All rights reserved.

=head1 LICENSE

Any commercial use of the Software requires a license directly from
the author(s).  Please contact the author(s) to negotiate an
appropriate license.  Commercial use includes integration of all or
part of the binary or source code covered by this permission
notices into a product for sale or license to third parties on your
behalf, or distribution of the binary or source code to third
parties that need it to utilize a product sold or licensed on your
behalf.

=cut

package Lingua::ZH::Romanize::Pinyin;
use strict;
use Carp;
use Storable;
use vars qw( $VERSION );
$VERSION = "0.13";

sub new {
    my $package = shift;
    my $store = shift || &_detect_store($package);
    Carp::croak "$! - $store\n" unless ( -r $store );
    my $self = Storable::retrieve($store) or Carp::croak "$! - $store\n";
    bless $self, $package;
    $self;
}

sub char {
    my $self = shift;
    my $char = shift;
    return unless exists $self->{$char};
    $self->{$char};
}

sub chars {
    my $self  = shift;
    my @array = $self->string(shift);
    join( " ", map { $#$_ > 0 ? $_->[1] : $_->[0] } @array );
}

sub string {
    my $self  = shift;
    my $src   = shift;
    my $array = [];
    while ( $src =~ /([\300-\377][\200-\277]+)|([\000-\177]+)/sg ) {
        if ( defined $1 ) {    # Chinese
            my $pair = [$1];
            $pair->[1] = $self->{$1} if exists $self->{$1};
            push( @$array, $pair );
        }
        else {
            push( @$array, [$2] );    # ASCII
        }
    }
    @$array;
}

#   Pinyin.pm -> Pinyin.store
#   Cantonese.pm -> Cantonese.store

sub _detect_store {
    my $package = shift;
    my $store = $INC{ join( "/", split( "::", "$package.pm" ) ) };
    $store =~ s#\.pm$#.store# or Carp::croak "Invalid module name: $package\n";
    $store;
}

1;
