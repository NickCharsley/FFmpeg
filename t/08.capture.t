use Test::More tests => 9;
use FFmpeg;
use Data::Dumper;

my $fname = "eg/t1.m2v";

ok(my $ff = FFmpeg->new(input_file => $fname) , 'ff object created successfully');
ok($ff->isa('FFmpeg')                         , 'object correct type');
ok(my $sg = $ff->create_streamgroup           , 'streamgroup object created successfully');
ok($sg->isa('FFmpeg::StreamGroup')            , 'object correct type');

ok($frame = $sg->capture_frame( duration => 0.001), 'captured frame');

ok(!$frame->Write(filename=>'t.ppm')          , 'wrote frame to file');
ok(-f 't.ppm'                                 , 'frame file exists');

ok($frame = $sg->capture_frames(duration => 1), 'captured new frame');
ok($frame                                     , 'new frame defined');
