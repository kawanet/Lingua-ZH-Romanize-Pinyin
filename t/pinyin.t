# ----------------------------------------------------------------
    use strict;
    use Test::More tests => 9;
    BEGIN { use_ok('Lingua::ZH::Romanize::Pinyin'); };
# ----------------------------------------------------------------
{
    my $roman = Lingua::ZH::Romanize::Pinyin->new();
    ok( ref $roman, "new" );

    ok( (! defined $roman->char("a")), "char: ascii" );
    is( $roman->char("\xE6\xBC\xA2"), "han4", "char: big5" );
    is( $roman->char("\xE6\xB1\x89"), "han",  "char: gb2312" );

    my $c4 = $roman->chars("\xe6\xbc\xa2\xe8\xaa\x9e");
    is( $c4, "han4 yu3/yu4", "chars: big5 [$c4]" );

    my $c5 = $roman->chars("\xe6\xb1\x89\xe8\xaf\xad");
    is( $c5, "han yu", "chars: gb2312 [$c5]" );

    my @list = $roman->string("\xE4\xBD\xA0\xE5\xA5\xBD");
    is( $list[0][1], "ni3",       "ni" );
    is( $list[1][1], "hao3/hao4", "hao" );
}
# ----------------------------------------------------------------
;1;
# ----------------------------------------------------------------
