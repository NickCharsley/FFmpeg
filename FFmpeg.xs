#ifdef __cplusplus
"C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <errno.h>

#include "ffmpeg.h"

/* these are from cmdutils.h, declared here so we don't need to link cmdutils.o */
void show_help_options(const OptionDef *options, const char *msg, int mask, int value){}
void print_error(const char *filename, int err){}
void parse_options(int argc, char **argv, const OptionDef *options){}

/* todo, make av_log() store the error log in a perl-accessible SV* */
/* void av_log(void *avcl, int level, const char *fmt, ...){} */

MODULE = FFmpeg PACKAGE = FFmpeg

PROTOTYPES: DISABLE

int
foo(self)
	SV *self;

	CODE:
	RETVAL = 1234;

	OUTPUT:
	RETVAL

void
_init_ffmpeg (self)
	SV *self;

	CODE:
	av_register_all();

void
_run_ffmpeg(self)
	SV *self;

	CODE:
	av_encode(output_files, nb_output_files, input_files, nb_input_files, stream_maps, nb_stream_maps);

# **********************************************************************
#
# setter functions to affect ffmpeg.c behavior.  these serve the same
# purpose as ffmpeg's commandline options.
#
# **********************************************************************

void
_cleanup(self)
	SV *self;

	CODE:
	nb_input_files  = 0;
	nb_output_files = 0;
	nb_stream_maps  = 0;

void
_set_format(self, arg)
	SV *self;
	char *arg;

	CODE:
	opt_format(arg);

void
_set_frame_rate(self, arg)
    SV *self;
    char *arg;

    CODE:
    opt_frame_rate(arg);

void
_set_frame_size(self, arg)
	SV *self;
	char *arg;

	CODE:
	opt_frame_size(arg);

void
_set_image_format(self, arg)
	SV *self;
	char *arg;

	CODE:
	opt_image_format(arg);

void
_set_input_file(self, arg)
	SV *self;
	char *arg;

	CODE:
	opt_input_file(arg);

void
_set_output_file(self, arg)
	SV *self;
	char *arg;

	CODE:
	opt_output_file(arg);

void
_set_overwrite(self, o)
	SV *self;
	int o;

	CODE:
	file_overwrite = o;

void
_set_recording_time(self, arg)
	SV *self;
	char *arg;

	CODE:
	opt_recording_time(arg);

void
_set_start_time(self, arg)
	SV *self;
	char *arg;

	CODE:
	opt_start_time(arg);

void
_set_verbose(self, v)
	SV *self;
	int v;

	CODE:
	verbose = v;

# **********************************************************************
#
# custom functions to access libavcodec/libavformat file/stream metadata
# from perl.
#
# **********************************************************************

HV*
_image_formats(self)
	SV *self;

	CODE:
	{

	HV *hash = newHV();

	AVInputFormat *ifmt;
	AVOutputFormat *ofmt;
	AVImageFormat *image_fmt;
	URLProtocol *up;
	AVCodec *p, *p2;
	const char **pp, *last_name;

	last_name = "000";

	for (image_fmt = first_image_format; image_fmt != NULL; image_fmt = image_fmt->next) {

		hv_store(
			hash, image_fmt->name, strlen(image_fmt->name), 
			newSVpvf("%s%s", image_fmt->img_read ? "D":" ", 
			image_fmt->img_write ? "E":" "), 0
		);
	}

	RETVAL = hash;

	}

	OUTPUT:
	RETVAL

HV* _file_formats(self)
	SV *self;

	CODE:
	{

	HV *hash = newHV();

	AVInputFormat *ifmt;
	AVOutputFormat *ofmt;
	AVImageFormat *image_fmt;
	URLProtocol *up;
	AVCodec *p, *p2;
	const char **pp, *last_name;

	// hv_store(hash, "callalert", strlen("callalert"), newSVpv("jkl;",0), 0);

	last_name = "000";

	for(;;) {

		int decode = 0;
		int encode = 0;
		const char *name=NULL;
		const char *longname=NULL;
		const char *mimetype=NULL;

		for (ofmt = first_oformat; ofmt != NULL; ofmt = ofmt->next) {

		if ((name == NULL || strcmp(ofmt->name, name)<0) && strcmp(ofmt->name, last_name)>0) {
			name= ofmt->name;
			longname= ofmt->long_name;
			mimetype= ofmt->mime_type;
			encode=1;
		}

		}

		for (ifmt = first_iformat; ifmt != NULL; ifmt = ifmt->next) {

			if ((name == NULL || strcmp(ifmt->name, name) < 0) && strcmp(ifmt->name, last_name)>0) {
				name= ifmt->name;
				longname= ifmt->long_name;
				encode=0;
			}

			if (name && strcmp(ifmt->name, name) == 0) {
				decode = 1;
			}
		}

		if (name == NULL) {
			break;
		}

		last_name= name;
		HV *codec = newHV();

		hv_store(hash, name, strlen(name), newRV_noinc((SV *) codec), 0);

		hv_store(codec,"capabilities",strlen("capabilities"),
			newSVpvf("%s%s", decode ? "D":" ", encode ? "E":" "),0
		);

		hv_store(codec,"name",strlen("name"), newSVpvf("%s",name),0);
		hv_store(codec,"description",strlen("description"), newSVpvf("%s",longname),0);

		if (mimetype) {
			hv_store(codec,"mime_type",strlen("mime_type"), newSVpvf("%s",mimetype),0);
		}
	}

	RETVAL = hash;
	}

	OUTPUT:
	RETVAL

int
_init_AVFormatContext(self)
	SV *self;

	CODE:
	RETVAL = (int)av_malloc(sizeof(AVFormatContext));

	OUTPUT:
	RETVAL

void
_free_AVFormatContext(self, ic_addr)
	SV *self;
	int ic_addr;

	CODE:
	{

	AVFormatContext *ic = (AVFormatContext *) ic_addr;
	av_free(ic);

	}

HV*
_init_streamgroup(self, ic_addr, filename)
	SV *self;
	int ic_addr;
	char *filename;

	CODE:
	{
	HV *hash = newHV();
	HV *stream = newHV();

	hv_store(hash,"stream",strlen("stream"), newRV_noinc((SV *) stream),0);

	AVFormatContext *ic = (AVFormatContext *) ic_addr;
	AVFormatParameters params, *ap = &params;
	int err, i, flags;
	char buf[256];

	ap->image_format = image_format;

	err = av_open_input_file(&ic, filename, file_iformat, 0, ap);

	if (err < 0) {
		hv_store(hash,"error",strlen("error"),newSVpvf("av_open_input_file returned: %d", err),0);
		XSRETURN_UNDEF;
	}

	err = av_find_stream_info(ic);

	if (err < 0) {
		hv_store(
			hash,"error",strlen("error"),
			newSVpvf("av_find_stream_info could not find codec parameters; returned: %d", err),0
		);

		XSRETURN_UNDEF;
	}

	hv_store(hash,"format",strlen("format"), newSVpvf("%s", ic->iformat->name,PL_na), 0);

	hv_store(hash,"url",   strlen("url"), newSVpvf("%s",filename),0);
	hv_store(hash,"title",strlen("title"), newSVpvf("%s",ic->title),0);
	hv_store(hash,"author",strlen("author"), newSVpvf("%s",ic->author),0);
	hv_store(hash,"copyright",strlen("copyright"), newSVpvf("%s",ic->copyright),0);
	hv_store(hash,"comment",strlen("comment"), newSVpvf("%s",ic->comment),0);
	hv_store(hash,"album",strlen("album"), newSVpvf("%s",ic->album),0);
	hv_store(hash,"genre",strlen("genre"), newSVpvf("%s",ic->genre),0);

	hv_store(hash,"year",strlen("year"), newSViv(ic->year),0);
	hv_store(hash,"track",strlen("track"), newSViv(ic->track),0);
	hv_store(hash,"file_size",strlen("file_size"), newSViv(ic->file_size),0);
	hv_store(hash,"data_offset",strlen("data_offset"), newSViv(ic->data_offset),0);

	if (ic->duration != AV_NOPTS_VALUE) {

        //
        // moving away from Time::Piece, let's try giving back the raw AVFormatContext duration
        // and time base (inverse seconds) to perl, and manipulating in there.  i suspect
        // this HH:MM:SS formatting is somehow causing malloc() unitialized memory problems under
        // mod_perl.
        //
		//int hours, mins, secs, dsecs;
		//secs  = ic->duration / AV_TIME_BASE;
		//dsecs = ic->duration % AV_TIME_BASE;
		//mins  = secs / 60;
		//secs %= 60;
		//hours = mins / 60;
		//mins %= 60;
		//hv_store(hash,"duration",strlen("duration"), newSVpvf("%02d:%02d:%02d", hours, mins, secs), 0);

        hv_store(hash,"duration",strlen("duration"),newSVpvf("%u",ic->duration), 0);
        hv_store(hash,"AV_TIME_BASE",strlen("AV_TIME_BASE"),newSViv(AV_TIME_BASE), 0);
	}

	hv_store(hash,"bit_rate",strlen("bit_rate"), newSViv(ic->bit_rate),0);

	for (i = 0; i < ic->nb_streams; i++) {

		AVStream *st = ic->streams[i];

		HV *tstream = newHV();

		char stream_name[9];
		snprintf(stream_name, 10, "stream%02d", i);

		hv_store(stream,stream_name,strlen(stream_name), newRV_noinc((SV *) tstream),0);

		AVCodecContext *ctx = st->codec;
		AVCodec *codec = ctx->codec;

		/* AVFormatContext values */
		hv_store(tstream,"index",strlen("index"), newSViv(st->index),0);
		hv_store(tstream,"id",strlen("id"), newSViv(st->id),0);
		hv_store(tstream,"real_frame_rate",strlen("real_frame_rate"), newSVnv(av_q2d(st->r_frame_rate)),0);
//fprintf(stderr,"A %f\n", av_q2d(st->r_frame_rate));
		hv_store(tstream,"real_frame_rate_base",strlen("real_frame_rate_base"), newSVnv(av_q2d(st->time_base)),0);
//fprintf(stderr,"B %f\n", av_q2d(st->time_base));
		//hv_store(tstream,"real_frame_rate_base",strlen("real_frame_rate_base"), newSViv(av_q2d(st->time_base)),0);
		hv_store(tstream,"start_time",strlen("start_time"), newSViv(st->start_time),0);
		hv_store(tstream,"duration",strlen("duration"), newSViv(st->duration),0);

		hv_store(tstream,"quality",strlen("quality"), newSVnv(st->quality),0);

		/* AVCodecContext values */
		hv_store(tstream,"bit_rate",strlen("bit_rate"), newSViv(ctx->bit_rate),0);
		hv_store(tstream,"bit_rate_tolerance",strlen("bit_rate_tolerance"), newSViv(ctx->bit_rate_tolerance),0);
//fprintf(stderr,"C %f\n", av_q2d(ctx->time_base));
		hv_store(tstream,"frame_rate",strlen("frame_rate"), newSVnv(av_q2d(ctx->time_base)),0);
		hv_store(tstream,"width",strlen("width"), newSViv(ctx->width),0);
		hv_store(tstream,"height",strlen("height"), newSViv(ctx->height),0);
		hv_store(tstream,"sample_rate",strlen("sample_rate"), newSViv(ctx->sample_rate),0);
		hv_store(tstream,"channels",strlen("channels"), newSViv(ctx->channels),0);
		hv_store(tstream,"sample_format",strlen("sample_format"), newSViv(ctx->sample_fmt),0);

		/* do we want to initalize these???
		hv_store(tstream,"frame_size",strlen("frame_size"), newSViv(ctx->frame_size),0);
		hv_store(tstream,"frame_number",strlen("frame_number"), newSViv(ctx->frame_number),0);
		hv_store(tstream,"real_pict_number",strlen("real_pict_number"), newSViv(ctx->real_pict_num),0);

		hv_store(tstream,"codec_name",strlen("codec_name"), newSVpvf("%s",ctx->codec_name),0); */

		hv_store(tstream,"codec_id",strlen("codec_id"), newSViv(ctx->codec_id),0);
		hv_store(tstream,"codec_tag",strlen("codec_tag"), newSVuv(ctx->codec_tag),0);

		/* PixelFormat - initialize?
		hv_store(tstream,"color_table_id",strlen("color_table_id"), newSViv(ctx->color_table_id),0); */
	}

	RETVAL = hash;
	}

	OUTPUT:
	RETVAL

HV*
_codecs(self)
	SV *self;

	CODE:
	{

	HV *hash = newHV();

	AVInputFormat *ifmt;
	AVOutputFormat *ofmt;
	AVImageFormat *image_fmt;
	URLProtocol *up;
	AVCodec *p, *p2;
	const char **pp, *last_name;

	last_name = "000";

	for (;;) {

		int decode=0;
		int encode=0;
		int cap=0;

		p2 = NULL;

		for (p = first_avcodec; p != NULL; p = p->next) {

			if ((p2==NULL || strcmp(p->name, p2->name)<0) && strcmp(p->name, last_name) > 0) {
				p2= p;
				decode= encode= cap=0;
			}

			if (p2 && strcmp(p->name, p2->name) == 0) {

				if (p->decode) decode = 1;
				if (p->encode) encode = 1;
				cap |= p->capabilities;
			}

		}

		if (p2 == NULL) {
			break;
		}

		last_name= p2->name;

		hv_store(hash, p2->name, strlen(p2->name),
			newSVpvf(
				"[%x]%s%s%s", p2->id, decode ? "D" : " ", 
				encode ? "E" : " ", p2->type == CODEC_TYPE_AUDIO ? "A" : "V"
			), 0
		);
	}

	RETVAL = hash;

	}

	OUTPUT:
	RETVAL
