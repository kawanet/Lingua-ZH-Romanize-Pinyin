use strict;
use ExtUtils::MakeMaker;
use lib qw( lib );
use Lingua::ZH::Romanize::DictZH;

Lingua::ZH::Romanize::DictZH->update();

WriteMakefile(
    NAME                => 'Lingua-ZH-Romanize-Pinyin',
    VERSION_FROM        => 'lib/Lingua/ZH/Romanize/Pinyin.pm',
    PREREQ_PM           => {
        'Test::More'    => '0',
        'Storable'      => '0',
    },
);
