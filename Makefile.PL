use ExtUtils::MakeMaker;
use Config;

$FFMPEG_ROOT = $ENV{FFMPEG_ROOT};
if(!defined($FFMPEG_ROOT)){
  die "you didn't define environmental variable \$FFMPEG_ROOT";
} elsif(opendir(ZZ,$FFMPEG_ROOT)){
  closedir(ZZ);
} else {
  die "couldn't opendir on \$FFMPEG_ROOT ('$FFMPEG_ROOT'): $!";
}

#
# ... now we're ready to start the module build & install process
#

$LDDLFLAGS = '';
$LDDLFLAGS = '-all_load' if $^O eq 'darwin';
$LDDLFLAGS = '-L/usr/pkg/lib' if $^O eq 'netbsd';

open(FFMPEGH, ">ffmpeg.h") or die $!;
print FFMPEGH "#include \"$FFMPEG_ROOT/ffmpeg.c\"\n";
close(FFMPEGH);

WriteMakefile(
      'NAME'          => 'FFmpeg',
      'VERSION_FROM'  => 'FFmpeg.pm',
      'DEFINE'        => '-O',
      'LDDLFLAGS'     => "$Config{'lddlflags'} $LDDLFLAGS",

      'PREREQ_PM'     => {
              Devel::Leak => 0,
              File::Temp => 0,
              HTTP::Request => 0,
              Image::Magick::Iterator   => 0.01,
              Image::PBMlib => 1.05, #1.06?
              LWP::UserAgent => 0,
              Time::Piece   => 1.08,
      },

      ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
          (ABSTRACT_FROM  => 'FFmpeg.pm', # retrieve abstract from module
           AUTHOR         => 'Allen Day <allenday@ucla.edu>') : ()),

      'PERL_MALLOC_OK'  => 1,
      'LIBS'            => ["-lavcodec -lavformat -lm -lz -ldl -lmp3lame -logg -lvorbis -lvorbisenc"],
      'INC'             => "-I$FFMPEG_ROOT/libavcodec -I$FFMPEG_ROOT/libavformat",
);
