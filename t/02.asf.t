use Test::More tests => 69;
use FFmpeg;
use Data::Dumper;

my $fname = "eg/t1.asf";

ok(my $ff = FFmpeg->new(input_file => $fname) , 'ff object created successfully');
ok($ff->isa('FFmpeg')                         , 'object correct type');
ok(my $sg = $ff->create_streamgroup           , 'streamgroup object created successfully');
ok($sg->isa('FFmpeg::StreamGroup')            , 'object correct type');

ok($sg->duration->isa('Time::Piece')          , 'object correct type');
is($sg->duration->hms, '00:00:00'             , 'streamgroup duration correct');
is(scalar($sg->streams), 6                    , 'stream count correct');
is(scalar(grep {$_->is_video} $sg->streams), 5, 'video stream count correct');
is(scalar(grep {$_->is_audio} $sg->streams), 0, 'audio stream count correct');

TODO: {
  local $TODO = "WMA/MPEG codec matrix lookups not finished";
  ok($sg->has_audio                           , 'audio detected ok');
}

ok($sg->has_video                             , 'video detected ok');

is($sg->album, 'The Living Trees'             , 'streamgroup album ok');
is($sg->author, 'AIMS Multimedia'             , 'streamgroup author ok');
is($sg->bit_rate, 82519                       , 'streamgroup bit_rate ok');
is($sg->comment, 'The Living Trees'           , 'streamgroup comment ok');
is($sg->copyright, '(C) 2002 AIMS Multimedia' , 'streamgroup copyright ok');
is($sg->data_offset, 4381                     , 'streamgroup data_offset ok');
is($sg->file_size, 10157                      , 'streamgroup file_size ok');
is($sg->format->name, 'asf'                   , 'streamgroup format ok');
is($sg->genre, ''                             , 'streamgroup genre ok');
is($sg->track, 0                              , 'streamgroup track ok');
is($sg->url, $fname                           , 'streamgroup url ok');
is($sg->year, 0                               , 'streamgroup year ok');

#warn Dumper($sg);

$fname = "eg/t2.asf";

ok($ff = FFmpeg->new(input_file => $fname)    , 'ff object created successfully');
ok($ff->isa('FFmpeg')                         , 'object correct type');
ok($sg = $ff->create_streamgroup              , 'streamgroup object created successfully');
ok($sg->isa('FFmpeg::StreamGroup')            , 'object correct type');

ok($sg->duration->isa('Time::Piece')          , 'object correct type');
is($sg->duration->hms, '00:00:06'             , 'streamgroup duration correct');
is(scalar($sg->streams), 2                    , 'stream count correct');
is(scalar(grep {$_->is_video} $sg->streams), 1, 'video stream count correct');
is(scalar(grep {$_->is_audio} $sg->streams), 0, 'audio stream count correct');

TODO: {
  local $TODO = "WMA/MPEG codec matrix lookups not finished";
  ok($sg->has_audio                           , 'audio detected ok');
}
ok($sg->has_video                             , 'video detected ok');

is($sg->album, 'The Living Trees'             , 'streamgroup album ok');
is($sg->author, 'AIMS Multimedia'             , 'streamgroup author ok');
is($sg->bit_rate, 380149                      , 'streamgroup bit_rate ok');
is($sg->comment, 'The Living Trees'           , 'streamgroup comment ok');
is($sg->copyright, '(C) 2002 AIMS Multimedia' , 'streamgroup copyright ok');
is($sg->data_offset, 4368                     , 'streamgroup data_offset ok');
is($sg->file_size, 292368                     , 'streamgroup file_size ok');
is($sg->format->name, 'asf'                   , 'streamgroup format ok');
is($sg->genre, ''                             , 'streamgroup genre ok');
is($sg->track, 0                              , 'streamgroup track ok');
is($sg->url, $fname                           , 'streamgroup url ok');
is($sg->year, 0                               , 'streamgroup year ok');

$fname = "eg/t3.asf";

ok($ff = FFmpeg->new(input_file => $fname)    , 'ff object created successfully');
ok($ff->isa('FFmpeg')                         , 'object correct type');
ok($sg = $ff->create_streamgroup              , 'streamgroup object created successfully');
ok($sg->isa('FFmpeg::StreamGroup')            , 'object correct type');

ok($sg->duration->isa('Time::Piece')          , 'object correct type');
is($sg->duration->hms, '02:18:36'             , 'streamgroup duration correct');
is(scalar($sg->streams), 2                    , 'stream count correct');
is(scalar(grep {$_->is_video} $sg->streams), 1, 'video stream count correct');
is(scalar(grep {$_->is_audio} $sg->streams), 1, 'audio stream count correct');

ok($sg->has_audio                             , 'audio detected ok');
ok($sg->has_video                             , 'video detected ok');

is($sg->album, ''                             , 'streamgroup album ok');
is($sg->author, 'UnKnôwn - Founder of [PC]'   , 'streamgroup author ok');
is($sg->bit_rate, 13                          , 'streamgroup bit_rate ok');
is($sg->comment, ''                           , 'streamgroup comment ok');
is($sg->copyright, '#100_____collectors - DalNet','streamgroup copyright ok');
is($sg->data_offset, 921                      , 'streamgroup data_offset ok');
is($sg->file_size, 14234                      , 'streamgroup file_size ok');
is($sg->format->name, 'asf'                   , 'streamgroup format ok');
is($sg->genre, ''                             , 'streamgroup genre ok');
is($sg->track, 0                              , 'streamgroup track ok');
is($sg->url, $fname                           , 'streamgroup url ok');
is($sg->year, 0                               , 'streamgroup year ok');


