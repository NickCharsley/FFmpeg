use Inline::MakeMaker;
use Config;
use File::Spec;
use File::Copy;

my %w = map {$_=>1} qw( FFMPEG_ROOT ); #wanted params here, value 1 for required, value 0 for optional
my %p = ();                            #store wanted param values here

#collect param values
for(my $i = 0 ; $i <= scalar(@ARGV) ; $i++){

  my($k,$v) = $ARGV[$i] =~ /^(.+)=(.+?)$/; #this will fail on backslashed '=' chars

  if($w{$k}){
    $p{$k} = $v;
    splice(@ARGV,$i);
  }

}

#make sure required params are given values
foreach my $w (keys %w){

  #try to capture from %ENV;
  if(!defined($p{$w}) and defined($ENV{$w})){
    $p{$w} = $ENV{$w};
  }

  next if $w{$w} == 0;
  print STDERR "\nno value for required parameter '$w' provided to Makefile.PL, did you read the README?\n\n" and exit() unless $p{$w};
}

#
# ... now we're ready to start the module build & install process
#

print(STDERR "Building FFmpeg.pm as: $Config{perlpath} FFmpeg.PMS FFmpeg.pm $p{FFMPEG_ROOT}\n");
system("$Config{perlpath} FFmpeg.PMS FFmpeg.pm $p{FFMPEG_ROOT}") and die "error building FFmpeg.pm: $!";

WriteInlineMakefile(
  'NAME'            => 'FFmpeg',
  'VERSION_FROM'    => 'FFmpeg.pm', # finds $VERSION
  'PREREQ_PM'       => {
                         Inline::C     => 0.44,
                         Time::Piece   => 1.08,
#                         Image::PBMlib => 1.06,
#                         Image::Magick => 5.56,
                       },
  ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
    (ABSTRACT_FROM  => 'FFmpeg.pm', # retrieve abstract from module
     AUTHOR         => 'Allen Day <allenday@ucla.edu>') : ()),

  'PERL_MALLOC_OK'  => 1,
  'CONFIG'          => ['lddlflags'],
  'LIBS'            => [qw(-L$p{FFMPEG_ROOT}/libavcodec -L$p{FFMPEG_ROOT}/libavformat -lavcodec -lavformat -lm -lz -ldl -lmp3lame -logg -lvorbis -lvorbisenc)],
  'DEFINE'          => '',
  'INC'             => "-I$p{FFMPEG_ROOT}/libavcodec -I$p{FFMPEG_ROOT}/libavformat",
  'OBJECT'          => "empty.o", #dunno why we need this... whatever
  'MYEXTLIB'        => '',
);
