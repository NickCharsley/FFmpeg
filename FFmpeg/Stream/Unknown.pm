=head1 NAME

FFmpeg::Stream::Unknown - A stream of unknown type from a (multi)media
stream group.

=head1 SYNOPSIS

  $ff = FFmpeg->new();             #see FFmpeg
  #...
  $sg = $ff->create_streamgroup(); #see FFmpeg
  $st = ($sg->streams())[0];       #this is a FFmpeg::Stream

=head1 DESCRIPTION

Objects of this class are not intended to be
instantiated directly by the end user.  Access
L<FFmpeg::Stream::Unknown|FFmpeg::Stream::Unknown> objects using methods in
L<FFmpeg::StreamGroup|FFmpeg::StreamGroup>.  See
L<FFmpeg::StreamGroup> for more information.

This class represents a stream of unknown type in a multimedia stream
group.  General stream attributes can be found in the
L<FFmpeg::Stream|FFmpeg::Stream> class.


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


package FFmpeg::Stream::Unknown;
use strict;
use base qw(FFmpeg::Stream);
our $VERSION = '0.01';

=head2 new()

This class inherits from L<FFmpeg::Stream|FFmpeg::Stream>.  See
L<FFmpeg::Stream/new()|FFmpeg::Stream::new()>

=cut

=head2 init()

This class inherits from L<FFmpeg::Stream|FFmpeg::Stream>.  See
L<FFmpeg::Stream/init()|FFmpeg::Stream::init()>

=cut

1;
