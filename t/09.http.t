use Test::More tests => 9;
BEGIN {
        use_ok('FFmpeg');
        use_ok('Data::Dumper');
      };

my $url = "http://sumo.genetics.ucla.edu/~allenday/ffmpeg.download.mpg";

print STDERR "\nNetwork inaccessibility will cause the following tests to fail\n";

my($ff,$sg);

ok($ff = FFmpeg->new(input_url => $url)          , 'ff object created successfully');
ok($sg = $ff->create_streamgroup()               , 'sg object created successfully');
ok($sg->has_video()                              , 'sg has video');
ok($sg->duration() =~ /00:00:05/                 , 'sg duration okay');

ok($ff = FFmpeg->new(input_url => $url,
                     input_url_referrer => 'http://foo.bar.com',
                     input_url_max_size => 50000), 'ff object created successfully');
ok($sg = $ff->create_streamgroup()               , 'sg object created successfully');
ok($sg->has_video()                              , 'sg has video');
#ok($sg->duration() =~ /00:00:05/                , 'sg duration okay');

