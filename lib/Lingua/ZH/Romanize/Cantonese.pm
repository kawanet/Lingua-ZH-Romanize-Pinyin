=head1 NAME

Lingua::ZH::Romanize::Cantonese - Romanization of Cantonese language

=head1 SYNOPSIS

    use Lingua::ZH::Romanize::Cantonese;

    my $conv = Lingua::ZH::Romanize::Cantonese->new();
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

This is Cantonese version of L<Lingua::ZH::Romanize::Pinyin> module.

Cantonese is one of the major dialects of Chinese language.
Its pronounciation is different from Mandarin Standard's.

=head1 DICTIONARY

This module's Hanji to roman mapping table is based on
both of CTLau.tit and CTLauBig5.tit which are distributed with cxterm.
Original files were prepared by Fung Fung Lee.

Sidney Lau's Cantonese transcription scheme as described in his book
"Elementary Cantonese", The Government Printer, Hong Kong, 1972.

=head1 SEE ALSO

L<Lingua::ZH::Romanize::Pinyin>

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

package Lingua::ZH::Romanize::Cantonese;
use strict;
use vars qw( $VERSION @ISA );
$VERSION = "0.13";
@ISA     = qw( Lingua::ZH::Romanize::Pinyin );
use Lingua::ZH::Romanize::Pinyin;

#   every methods are provided by Lingua::ZH::Romanize::Pinyin!

1;
