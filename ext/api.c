#include "ruby.h"
#include "snappy-c.h"

static VALUE rb_mSnappy;
static VALUE rb_eSnappy;

static VALUE
snappy_raise(snappy_status result)
{
    if (result == SNAPPY_INVALID_INPUT) {
        rb_raise(rb_eSnappy, "INVALID INPUT");
    } else if (result == SNAPPY_BUFFER_TOO_SMALL) {
        rb_raise(rb_eSnappy, "BUFFER TOO SMALL");
    } else {
        rb_raise(rb_eSnappy, "ERROR");
    }
    return Qnil;
}

static VALUE
snappy_deflate(int argc, VALUE *argv, VALUE self)
{
    VALUE src, dst;
    size_t  output_length;
    snappy_status result;

    rb_scan_args(argc, argv, "11", &src, &dst);
    StringValue(src);

    output_length = snappy_max_compressed_length(RSTRING_LEN(src));

    if (NIL_P(dst)) {
        dst = rb_str_new(NULL, output_length);
    } else {
    	StringValue(dst);
    	rb_str_resize(dst, output_length);
    }

    result = snappy_compress(RSTRING_PTR(src), RSTRING_LEN(src), RSTRING_PTR(dst), &output_length);
    if (result == SNAPPY_OK) {
        rb_str_resize(dst, output_length);
        return dst;
    } else {
        return snappy_raise(result);
    }
}

static VALUE
snappy_inflate(int argc, VALUE *argv, VALUE self)
{
    VALUE src, dst;
    size_t output_length;
    snappy_status result;

    rb_scan_args(argc, argv, "11", &src, &dst);
    StringValue(src);

    result = snappy_uncompressed_length(RSTRING_PTR(src), RSTRING_LEN(src), &output_length);
    if (result != SNAPPY_OK) {
        return snappy_raise(result);
    }

    if (NIL_P(dst)) {
        dst = rb_str_new(NULL, output_length);
    } else {
    	StringValue(dst);
    	rb_str_resize(dst, output_length);
    }

    result = snappy_uncompress(RSTRING_PTR(src), RSTRING_LEN(src), RSTRING_PTR(dst), &output_length);
    if (result != SNAPPY_OK) {
        return snappy_raise(result);
    }

    StringValue(dst);
    rb_str_resize(dst, output_length);

    return dst;
}

void Init_snappy_ext()
{
    rb_mSnappy = rb_define_module("Snappy");
    rb_eSnappy = rb_define_class_under(rb_mSnappy, "Error", rb_eStandardError);
    rb_define_singleton_method(rb_mSnappy, "deflate", snappy_deflate, -1);
    rb_define_singleton_method(rb_mSnappy, "inflate", snappy_inflate, -1);

    VALUE rb_mSnappy_singleton = rb_singleton_class(rb_mSnappy);

    rb_define_alias(rb_mSnappy_singleton, "compress", "deflate");
    rb_define_alias(rb_mSnappy_singleton, "dump", "deflate");

    rb_define_alias(rb_mSnappy_singleton, "uncompress", "inflate");
    rb_define_alias(rb_mSnappy_singleton, "load", "inflate");
  }
