=head1 NAME

FFmpeg::Stream - An audio or video stream from a (multi)media file.

=head1 SYNOPSIS

  $ff = FFmpeg->new();             #see FFmpeg
  #...
  $sg = $ff->create_streamgroup(); #see FFmpeg
  $st = ($sg->streams())[0];       #this is a FFmpeg::Stream

=head1 DESCRIPTION

Objects of this class are not intended to be
instantiated directly by the end user.  Access
L<FFmpeg::Stream|FFmpeg::Stream> objects using methods in
L<FFmpeg::StreamGroup|FFmpeg::StreamGroup>.  See
L<FFmpeg::StreamGroup> for more information.

This class represents a media stream in a multimedia
file.  B<FFmpeg-Perl> represents multimedia file
information in a L<FFmpeg::StreamGroup|FFmpeg::StreamGroup> object, which is
a composite of L<FFmpeg::Stream|FFmpeg::Stream> objects.

L<FFmpeg::Stream|FFmpeg::Stream> objects don't do much.  They just keep
track of the media stream's ID within the multimedia
file, and hold an instance to a L<FFmpeg::Codec|FFmpeg::Codec> object
if the codec of the stream was deducible.  See
L<FFmpeg::Codec> for more information about how
codecs are represented.

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


package FFmpeg::Stream;
use strict;
use base qw();
our $VERSION = '0.01';

=head2 new()

=over

=item Usage

my $obj = new L<FFmpeg::Stream|FFmpeg::Stream>();

=item Function

Builds a new L<FFmpeg::Stream|FFmpeg::Stream> object

=item Returns

an instance of L<FFmpeg::Stream|FFmpeg::Stream>

=item Arguments

=over

=item fourcc (optional)

the four-character-code of the stream's codec.  this is
not used in any way by FFmpeg.

=item codec (optional)

a L<FFmpeg::Codec|FFmpeg::Codec> object used to decode this stream.
currently this is only used for decoding purposes, but
when transcoding/encoding is implemented in
B<FFmpeg-Perl>, this will be used to set an encoding codec.

=item codec_tag (optional)

fourcc converted to an unsigned int.

=back

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

Internal method to initialize a new L<FFmpeg::Stream|FFmpeg::Stream> object

=item Returns

true on success

=item Arguments

Arguments passed to new

=back

=cut

sub init {
  my($self,%arg) = @_;

  foreach my $arg (keys %arg){
    $self->$arg($arg{$arg}) if $self->can($arg);
  }

  return 1;
}

=head2 fourcc()

=over

=item Usage

 $obj->fourcc();        #get existing value

 $obj->fourcc($newval); #set new value

=item Function

stores the fourcc (four character code) of the stream's codec

=item Returns

value of fourcc (a scalar)

=item Arguments

=over

=item (optional) on set, a scalar

=back

=back

=cut

sub fourcc {
  my $self = shift;

  return $self->{'fourcc'} = shift if defined(@_);
  return $self->{'fourcc'};
}

=head2 codec()

=over

=item Usage

 $obj->codec();        #get existing FFmpeg::Codec

 $obj->codec($newval); #set new FFmpeg::Codec

=item Function


=item Returns

an object of class L<FFmpeg::Codec|FFmpeg::Codec>

=item Arguments

=over

=item (optional) on set, an object of class L<FFmpeg::Codec|FFmpeg::Codec>

=back

=back

=cut

sub codec {
  my($self,$obj) = @_;

  if(defined($obj)){
    $self->throw($obj . "must be or inherit from FFmpeg::Codec, but does not")
      unless ref($obj) and $obj->isa('FFmpeg::Codec');
    $self->{'codec'} = $obj;
  }
  return $self->{'codec'};
}

=head2 codec_tag()

=over

=item Usage

 $obj->codec_tag();        #get existing value

 $obj->codec_tag($newval); #set new value

=item Function

store the codec tag associated with the stream.  this
is similar to the value of fourcc(), but is an unsigned
int conversion of the fourcc.  this attribute is not used
in any way.

=item Returns

value of codec_tag (a scalar)

=item Arguments

=over

=item (optional) on set, a scalar

=back

=back

=cut

sub codec_tag {
  my $self = shift;

  return $self->{'codec_tag'} = shift if defined(@_);
  return $self->{'codec_tag'};
}

=head2 is_audio()

=over

=item Usage

$obj->is_audio(); #get existing value

=item Function

is the codec of this stream an audio codec?

=item Returns

a boolean, derived from the associated L<FFmpeg::Codec|FFmpeg::Codec>,
see L</codec()>.

=item Arguments

none, read-only

=back

=cut

sub is_audio {
  my $self = shift;
  return undef unless $self->codec;
  return $self->codec->is_audio;
}

=head2 is_video()

=over

=item Usage

$obj->is_video(); #get existing value

=item Function

is the codec of this stream a video codec?

=item Returns

a boolean, derived from the associated L<FFmpeg::Codec|FFmpeg::Codec>,
see L</codec()>.

=item Arguments

none, read-only

=back

=cut

sub is_video {
  my $self = shift;
  return undef unless $self->codec;
  return $self->codec->is_video;
}


1;
