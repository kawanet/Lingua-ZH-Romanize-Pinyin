use strict;
use ExtUtils::MakeMaker;

{
    local $@;
    eval {
        use lib qw( lib );
        use Lingua::ZH::Romanize::DictZH;
        Lingua::ZH::Romanize::DictZH->update();
    };
    warn "**** $@" if $@;
}

my $opt = {
    NAME                    =>  'Lingua::ZH::Romanize::Pinyin',
    VERSION_FROM            =>  'lib/Lingua/ZH/Romanize/Pinyin.pm',
    PREREQ_PM               =>  {
        'Test::More'        =>  '0',
        'Storable'          =>  '0',
    },
};

my $PERL581 = 1 if ( $] >= 5.008001 );
$opt->{PREREQ_PM}->{'Unicode::Map'} = '0' unless $PERL581;
$opt->{PREREQ_PM}->{'Unicode::String'} = '0' unless $PERL581;

WriteMakefile( %$opt );
