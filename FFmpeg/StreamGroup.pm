=head1 NAME

FFmpeg::StreamGroup - A group of related media streams, typically encapsulated in a single file

=head1 SYNOPSIS

  $ff = FFmpeg->new() #see FFmpeg;
  #...
  $sg = $ff->build_streamgroup();

=head1 DESCRIPTION

Objects of this class are not intended to be
instantiated directly by the end user.  Access
L<FFmpeg::StreamGroup|FFmpeg::StreamGroup> objects using methods in
L<FFmpeg|FFmpeg>.  Refer to L<FFmpeg> for more information.

This is a composite class of L<FFmpeg::Stream|FFmpeg::Stream> objects.
A StreamGroup in most cases maps directly to a file, but it is also possible
that it can represent data coming over a socket (eg HTTP), filehandle
(eg STDIN), or a peripheral device (eg a TV tuner card).

A media stream, represented by the L<FFmpeg::Stream|FFmpeg::Stream> class
is never created without a parent stream group.  Metadata that may be attached
to a stream is always attached to the group which contains the stream.

An example of this is an MP3 file which has been ID3 "tagged".  Metadata regarding
the MP3 audio data in the file, such as year of recording, artist name, album
name, and genre are attached to a L<FFmpeg::StreamGroup|FFmpeg::StreamGroup>
rather than onto the L<FFmpeg::Stream|FFmpeg::Stream> object representing the
audio data itself.

The L<FFmpeg::StreamGroup|FFmpeg::StreamGroup> object is useful not only for
retrieving stream group metadata, but also for inspecting the component streams
of the group.  See L</streams()> for details.

This class also has rudimentary support for transcoding, in the form of a
"frame grab".  See L</capture_frame()> for details.

=head1 FEEDBACK

See L<FFmpeg/FEEDBACK> for details.

=head1 AUTHOR

Allen Day E<lt>allenday@ucla.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2003-2004 Allen Day

This library is released under GPL, the Gnu Public License

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a '_'.  Methods are
in alphabetical order for the most part.

=cut


# Let the code begin...


package FFmpeg::StreamGroup;
use strict;
use Data::Dumper;
use File::Copy;
use File::Temp qw(tempfile tempdir);
use base qw();
our $VERSION = '0.01';

=head2 new()

=over

=item Usage

my $obj = new L<FFmpeg::StreamGroup|FFmpeg::StreamGroup>();

=item Function

Builds a new L<FFmpeg::StreamGroup|FFmpeg::StreamGroup> object

=item Returns

an instance of L<FFmpeg::StreamGroup|FFmpeg::StreamGroup>

=item Arguments

All optional, refer to the documentation of L<FFmpeg/new()>, this constructor
operates in the same way.

=back

=cut

sub new {
  my($class,%arg) = @_;

  my $self = bless {}, $class;
  $self->init(%arg);

  return $self;
}

=head2 init()

=over

=item Usage

$obj->init(%arg);

=item Function

Internal method to initialize a new L<FFmpeg::StreamGroup|FFmpeg::StreamGroup> object

=item Returns

true on success

=item Arguments

Arguments passed to new

=back

=cut

sub init {
  my($self,%arg) = @_;

  foreach my $arg (keys %arg){
    $self->{$arg} = $arg{$arg};
  }

  return 1;
}

=head2 streams()

=over

=item Usage

@arr = $obj->streams();

=item Function

get the list of streams associated with this
stream group.

=item Returns

a list of L<FFmpeg::Stream|FFmpeg::Stream> objects

=item Arguments

none, read only

=back

=cut

sub streams() {
  my $self = shift;
  return @{$self->{'_streams'}} if $self->{'_streams'};
  return ();
}

=head2 _add_stream()

=over

=item Usage

$obj->_add_stream();

=item Function

internal method.  add one or more streams to this stream group.

=item Returns

true on success

=item Arguments

one or more L<FFmpeg::Stream|FFmpeg::Stream> objects

=back

=cut

sub _add_stream {
  my $self = shift;

  foreach my $i (@_){
    die(qq(_add_stream received an object ($i) that didn't inherit from FFmpeg::Stream)) unless ref($i) and $i->isa('FFmpeg::Stream');
    push(@{$self->{'_streams'}}, $i);
  }
}

=head2 album()

=over

=item Usage

$obj->album(); #get existing value

=item Function

album name of stream group, if applicable

=item Returns

value of album (a scalar)

=item Arguments

none, read-only

=back

=cut

sub album {
  my $self = shift;

  return $self->{'album'};
}

=head2 author()

=over

=item Usage

$obj->author(); #get existing value

=item Function

entity responsible for encoding the stream group

=item Returns

value of author (a scalar)

=item Arguments

none, read-only

=back

=cut

sub author() {
  my $self = shift;
  return $self->{'author'};
}

=head2 bit_rate()

=over

=item Usage

$obj->bit_rate(); #get existing value

=item Function

average bit rate of stream group, in bits/second.

=item Returns

value of bit_rate (a scalar)

=item Arguments

none, read-only

=item Notes

some stream encoders do not store this value
in bits/second, but in Kbits/second, or other
unknown units.  this L<FFmpeg::StreamGroup|FFmpeg::StreamGroup>
attribute should be considered accordingly.

 From the FFmpeg documentation:
 ------------------------------

if file_size() and duration() are available,
the return value is calculated.  otherwise, the
return value is extracted from the stream group,
and is zero if not available.

=back

=cut

sub bit_rate {
  my $self = shift;

  return $self->{'bit_rate'};
}

=head2 comment()

=over

=item Usage

$obj->comment(); #get existing value

=item Function

comment on the stream group, if any

=item Returns

value of comment (a scalar)

=item Arguments

none, read-only

=back

=cut

sub comment {
  my $self = shift;

  return $self->{'comment'};
}

=head2 copyright()

=over

=item Usage

$obj->copyright(); #get existing value

=item Function

copyright notice on stream group, if any

=item Returns

value of copyright (a scalar)

=item Arguments

none, read-only

=back

=cut

sub copyright {
  my $self = shift;

  return $self->{'copyright'};
}

=head2 data_offset()

=over

=item Usage

$obj->data_offset(); #get existing value

=item Function

offset, in bytes, of first stream data.  this
is effectively the size of the file header.

=item Returns

value of data_offset (a scalar)

=item Arguments

none, read-only

=back

=cut

sub data_offset {
  my $self = shift;

  return $self->{'data_offset'};
}

=head2 duration()

=over

=item Usage

 $obj->duration();        #get existing Time::Piece

=item Function

duration of the stream group.  this is
initialized to '00:00:00' if duration information
is for some reason unable from the streamgroup.

=item Returns

an object of class Time::Piece

=item Arguments

none, read only

=back

=cut

sub duration {
  my($self,$obj) = @_;

  return $self->{'duration'};
}

=head2 file_size()

=over

=item Usage

$obj->file_size(); #get existing value

=item Function

file size of stream group, in bytes

=item Returns

value of file_size (a scalar)

=item Arguments

none, read-only

=back

=cut

sub file_size {
  my $self = shift;

  return $self->{'file_size'};
}

=head2 format()

=over

=item Usage

 $obj->format();        #get existing FFmpeg::FileFormat

=item Function

format of the stream group (eg mpeg, avi, mov, &c)

=item Returns

an object of class L<FFmpeg::FileFormat|FFmpeg::FileFormat>

=item Arguments

none, read-only

=back

=cut

sub format {
  my($self,$obj) = @_;

  return $self->{'format'};
}

=head2 genre()

=over

=item Usage

$obj->genre(); #get existing value

=item Function

genre of stream group, if applicable

=item Returns

value of genre (a scalar)

=item Arguments

none, read-only

=back

=cut

sub genre {
  my $self = shift;

  return $self->{'genre'};
}

=head2 has_audio()

=over

=item Usage

$obj->has_audio(); #get existing value

=item Function

detect if stream group contains audio

=item Returns

true if any of the contained L<FFmpeg::Stream|FFmpeg::Stream>
objects is an audio stream, false otherwise

=item Arguments

none, read-only

=back

=cut

sub has_audio() {
  my $self = shift;

  if(!defined($self->{'has_audio'})){
    foreach my $stream ( $self->streams ){
      $self->{'has_audio'}++ and last if $stream->is_audio;
    }
  }

  return $self->{'has_audio'};
}

=head2 has_video()

=over

=item Usage

$obj->has_video(); #get existing value

=item Function

detect if stream group contains video

=item Returns

true if any of the contained L<FFmpeg::Stream|FFmpeg::Stream>
objects is an video stream, false otherwise

=item Arguments

none, read-only

=back

=cut

sub has_video() {
  my $self = shift;

  if(!defined($self->{'has_video'})){
    foreach my $stream ( $self->streams ){
      $self->{'has_video'}++ and last if $stream->is_video;
    }
  }

  return $self->{'has_video'};
}

=head2 height()

=over

=item Usage

$obj->height(); #get existing value

=item Function

height of first video stream in group.  it
is not implemented to access heights of other
streams if they differ from the first.

=item Returns

value of height (a scalar)

=item Arguments

none, read-only

=back

=cut

sub height {
  my $self = shift;

  return $self->{'height'};
}

=head2 track()

=over

=item Usage

$obj->track(); #get existing value

=item Function

track number of stream group, if applicable

=item Returns

value of track (a scalar)

=item Arguments

none, read-only

=back

=cut

sub track {
  my $self = shift;

  return $self->{'track'};
}

=head2 url()

=over

=item Usage

$obj->url(); #get existing value

=item Function

url or system path of the stream group (ie path to file)

=item Returns

value of url (a scalar)

=item Arguments

none, read-only

=back

=cut

sub url {
  my $self = shift;

  return $self->{'url'};
}

=head2 width()

=over

=item Usage

$obj->width(); #get existing value

=item Function

width of first video stream in group.  it
is not implemented to access widths of other
streams if they differ from the first.

=item Returns

value of width (a scalar)

=item Arguments

none, read-only

=back

=cut

sub width {
  my $self = shift;

  return $self->{'width'};
}

=head2 year()

=over

=item Usage

$obj->year(); #get existing value

=item Function

production year of stream group, if applicable

=item Returns

value ofyear (a scalar)

=item Arguments

none, read-only

=back

=cut

sub year {
  my $self = shift;

  return $self->{'year'};
}

=head2 _ffmpeg()

=over

=item Usage

$obj->_ffmpeg(); #get existing value

=item Function

internal method.  holds a reference to a L<FFmpeg|FFmpeg>
object.  use this to manipulate B<FFmpeg-C>'s state.

=item Returns

value of _ffmpeg (a scalar)

=item Arguments

none, read-only

=back

=cut

sub _ffmpeg {
  my $self = shift;

  return $self->{'_ffmpeg'};
}

=head2 capture_frame()

=over

=item Usage

C<
$obj->capture_frame(
                    image_format => $ffmpeg_format,
                    start_time   => $time_piece,
                    frame_size   => "320x240",
                    output_file  => "/path/to/file.ppm",
);
>

=item Function

capture a frame from a streamgroup.  currently
implemented to capture only from first video
stream, patches welcome.

=item Returns

a filehandle on image data on the frame requested in
the format requested

=item Arguments

=over

=item frame_size (optional)

dimensions for image as a width x height string (eg "320x240").
defaults to streamgroup's native frame size

=item image_format (optional)

a L<FFmpeg::ImageFormat|FFmpeg::ImageFormat> object for the output format to be used.
defaults to PPM format

=item output_file (optional)

path to filename where captured frame willbe written.  defaults
to an anonymous tempfile created using L<File::Temp|File::Temp> that is
deleted upon program termination

=item start_time (optional)

a L<Time::Piece|Time::Piece> object or string in HH:MM:SS format specifying
offset at which to capture the frame. defaults to 00:00:00

=back

=back

=cut

sub capture_frame {
  my ($self,%arg) = @_;

  #
  #setup parameters for frame capture
  #
  #warn $self->url;
  $self->_ffmpeg->_set_input_file($self->url);
  $self->_ffmpeg->_set_recording_time('00:00:00.001');

  $self->_ffmpeg->_set_format('image');

  my($fh, $fn);
  if(!defined($arg{output_file})){
    ($fh, $fn) = tempfile(UNLINK => 1);
  } else {
    $fn = $arg{output_file};
  }

  if($arg{frame_size}){
    $self->_ffmpeg->_set_frame_size($arg{frame_size});
  }

  if(defined($arg{start_time}) and $arg{start_time}->isa('Time::Piece')){
    my $t = $self->_ffmpeg->create_timepiece($arg{start_time});
    $self->_ffmpeg->_set_start_time(
                                    sprintf(
                                            "%02d:%02d:%02d",
                                            $t->hour,
                                            $t->min,
                                            $t->sec
                                           )
                                   );
  } else {
    $self->_ffmpeg->_set_start_time('00:00:00');
  }

  if(defined($arg{image_format}) and $arg{image_format}->isa('FFmpeg::ImageFormat')){
    my $f = $arg{image_format};

    $self->_ffmpeg->_set_image_format($f->name);
#    $self->_ffmpeg->_set_format($f->name);
  } else {
    $self->_ffmpeg->_set_image_format('ppm');
#    $self->_ffmpeg->_set_format('ppm');
  }

  $self->_ffmpeg->_set_output_file("$fn.%d");

  $self->_ffmpeg->_run_ffmpeg();

  move("$fn.1",$fn);
  open($fh,$fn) or die "couldn't open '$fn': $!";

#  my $im = Image::Magick->new;
#  $im->Read(file => $fh);

#  printf("\n\nimage (%dx%d) written to: %s\n\n", $im->Get('width'), $im->Get('height'), $fn);

#  $im->Equalize();
#  $im->Write(filename=>'foo.bar.jpg');

  $self->_ffmpeg->_cleanup();

  return $fh;
}

1;
