use Test::More tests => 62;
BEGIN {
        use_ok('FFmpeg');
        use_ok('Data::Dumper');
      };

my $fname = "eg/t1.m2v";

ok(my $ff = FFmpeg->new(input_file => $fname) , 'ff object created successfully');
ok($ff->isa('FFmpeg')                                , 'object correct type');
is($ff->foo, 1234                                           , 'foo() call passed');

ok(my @file_formats = (sort {$a->name cmp $b->name} $ff->file_formats), 'file formats initialized');

#
# test file formats
#
ok(@file_formats = (sort {$a->name cmp $b->name} $ff->file_formats), 'file formats initialized');

#warn Dumper @file_formats;

is(ref($file_formats[0]),'FFmpeg::FileFormat', 'file format objects created successfully');

is($file_formats[3]->name, 'ac3',             'ac3 format available');
is($file_formats[3]->can_read,  1,            'ac3 format readable');
is($file_formats[3]->can_write, 1,            'ac3 format writable');
is($file_formats[3]->description, 'raw ac3',  'ac3 description');
is($file_formats[3]->mime_type, 'audio/x-ac3','ac3 mime');

is($file_formats[6]->name, 'asf_stream',         'asf_stream format available');
is($file_formats[6]->can_read,  0,               'asf_stream format not readable');
is($file_formats[6]->can_write, 1,               'asf_stream format writable');
is($file_formats[6]->description, 'asf format',  'asf_stream description');
is($file_formats[6]->mime_type, 'video/x-ms-asf','asf_format mime');

is($file_formats[12]->name, 'dv1394',                'dv1394 format available');
is($file_formats[12]->can_read,  1,                  'dv1394 format readable');
is($file_formats[12]->can_write, 0,                  'dv1394 format notwritable');
is($file_formats[12]->description, 'dv1394 A/V grab','dv1394 description');
is($file_formats[12]->mime_type, '',                 'dv1394 mime');

is_deeply($ff->file_format('ac3'),        $file_formats[3], 'file_format retrieval successful');
is_deeply($ff->file_format('asf_stream'), $file_formats[6], 'file_format retrieval successful');
is_deeply($ff->file_format('dv1394'),     $file_formats[12],'file_format retrieval successful');

#
# test image formats
#
ok(my @image_formats = (sort {$a->name cmp $b->name} $ff->image_formats), 'image formats initialized');

#warn Dumper @image_formats;

is(ref($image_formats[0]),'FFmpeg::ImageFormat', 'image format objects created successfully');

is($image_formats[0]->name, 'gif',         'gif format available');
is($image_formats[0]->can_read,  1,        'gif format readable');
is($image_formats[0]->can_write, 1,        'gif format writable');

is($image_formats[3]->name, 'pbm',         'pbm format available');
is($image_formats[3]->can_read,  0,        'pbm format not readable');
is($image_formats[3]->can_write, 1,        'pbm format writable');

is($image_formats[7]->name, 'pnm',         'pnm format available');
is($image_formats[7]->can_read,  1,        'pnm format readable');
is($image_formats[7]->can_write, 0,        'pnm format not writable');

is_deeply($ff->image_format('gif'), $image_formats[0], 'image_format retrieval successful');
is_deeply($ff->image_format('pbm'), $image_formats[3], 'image_format retrieval successful');
is_deeply($ff->image_format('pnm'), $image_formats[7], 'image_format retrieval successful');

#
# test codecs
#
ok(my @codecs = (sort {$a->name cmp $b->name} $ff->codecs), 'codecs initialized');

#warn Dumper(sort {$a->id <=> $b->id} @codecs);

is(ref($codecs[0]),'FFmpeg::Codec', 'codec objects created successfully');

is($codecs[0]->name, '4xm',         '4xm codec available');
is($codecs[0]->can_read,  1,        '4xm codec readable');
is($codecs[0]->can_write, 0,        '4xm codec not writable');
is($codecs[0]->is_video, 1,         '4xm codec is video');
is($codecs[0]->is_audio, 0,         '4xm codec is not audio');
is($codecs[0]->id, 44,              '4xm codec id');

is($codecs[2]->name, 'ac3',         'ac3 codec available');
is($codecs[2]->can_read,  0,        'ac3 codec not readable');
is($codecs[2]->can_write, 1,        'ac3 codec writable');
is($codecs[2]->is_video, 0,         'ac3 codec is not video');
is($codecs[2]->id, 10,              'ac3 codec id');

is($codecs[14]->name, 'asv1',       'asv1 codec available');
is($codecs[14]->can_read,  1,       'asv1 codec readable');
is($codecs[14]->can_write, 1,       'asv1 codec writable');
is($codecs[14]->is_video, 1,        'asv1 codec is video');
is($codecs[14]->is_audio, 0,        'asv1 codec is not audio');
is($codecs[14]->id, 41,             'asv1 codec id');

is_deeply($ff->codec('4xm'),  $codecs[0], 'codec retrieval successful');
is_deeply($ff->codec('ac3'),  $codecs[2], 'codec retrieval successful');
is_deeply($ff->codec('asv1'), $codecs[14],'codec retrieval successful');

