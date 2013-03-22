#include "ruby.h"
#include "snappy.h"

static VALUE rb_mSnappy;
static VALUE rb_eSnappy;

static VALUE
snappy_deflate(int argc, VALUE *argv, VALUE self)
{
    VALUE src, dst;
    size_t  output_length;

    rb_scan_args(argc, argv, "11", &src, &dst);
    StringValue(src);

    output_length = snappy::MaxCompressedLength(RSTRING_LEN(src));

    if (NIL_P(dst)) {
        dst = rb_str_new(NULL, output_length);
    } else {
    	StringValue(dst);
    	rb_str_resize(dst, output_length);
    }

    snappy::RawCompress(RSTRING_PTR(src), RSTRING_LEN(src), RSTRING_PTR(dst), &output_length);
    rb_str_resize(dst, output_length);

    return dst;
}

static VALUE
snappy_inflate(int argc, VALUE *argv, VALUE self)
{
    VALUE src, dst;
    size_t output_length;

    rb_scan_args(argc, argv, "11", &src, &dst);
    StringValue(src);

    if (!snappy::GetUncompressedLength(RSTRING_PTR(src), RSTRING_LEN(src), &output_length)) {
        rb_raise(rb_eSnappy, "snappy::GetUncompressedLength");
    }

    if (NIL_P(dst)) {
        dst = rb_str_new(NULL, output_length);
    } else {
    	StringValue(dst);
    	rb_str_resize(dst, output_length);
    }

    if (!snappy::RawUncompress(RSTRING_PTR(src), RSTRING_LEN(src), RSTRING_PTR(dst))) {
        rb_raise(rb_eSnappy, "snappy::RawUncompress");
    }

    return dst;
}

extern "C" {
void Init_snappy()
{
    rb_mSnappy = rb_define_module("Snappy");
    rb_eSnappy = rb_define_class_under(rb_mSnappy, "Error", rb_eStandardError);
    rb_define_singleton_method(rb_mSnappy, "deflate", (VALUE (*)(...))snappy_deflate, -1);
    rb_define_singleton_method(rb_mSnappy, "inflate", (VALUE (*)(...))snappy_inflate, -1);

    VALUE rb_mSnappy_singleton = rb_singleton_class(rb_mSnappy);

    rb_define_alias(rb_mSnappy_singleton, "compress", "deflate");
    rb_define_alias(rb_mSnappy_singleton, "load", "deflate");

    rb_define_alias(rb_mSnappy_singleton, "uncompress", "inflate");
    rb_define_alias(rb_mSnappy_singleton, "dump", "inflate");
    
    rb_require("snappy/writer");
    rb_require("snappy/reader");
}
}
