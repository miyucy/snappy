#include "ruby.h"
#include "snappy.h"

static VALUE rb_mSnappy;

static VALUE
snappy_deflate(int argc, VALUE *argv, VALUE self)
{
    VALUE src, dst;
    snappy::string output;
    size_t  output_length;

    rb_scan_args(argc, argv, "11", &src, &dst);
    src = StringValue(src);

    output_length = snappy::Compress(RSTRING_PTR(src), RSTRING_LEN(src), &output);
    if (NIL_P(dst)) {
        return rb_str_new(output.data(), output_length);
    } else {
    	StringValue(dst);
    	rb_str_resize(dst, output_length);
    	memcpy(RSTRING_PTR(dst), output.data(), output_length);
    }
}

static VALUE
snappy_inflate(int argc, VALUE *argv, VALUE self)
{
    VALUE src, dst;
    snappy::string output;

    rb_scan_args(argc, argv, "11", &src, &dst);
    src = StringValue(src);

    if (!snappy::IsValidCompressedBuffer(RSTRING_PTR(src), RSTRING_LEN(src)) ||
        !snappy::Uncompress(RSTRING_PTR(src), RSTRING_LEN(src), &output)) {
        rb_raise(rb_eRuntimeError, "Couldn't inflate");
    }

    if (NIL_P(dst)) {
        return rb_str_new(output.data(), output.size());
    } else {
    	StringValue(dst);
    	rb_str_resize(dst, output.size());
    	memcpy(RSTRING_PTR(dst), output.data(), output.size());
    }
}

extern "C" {
void Init_snappy()
{
    rb_mSnappy = rb_define_module("Snappy");
    rb_define_singleton_method(rb_mSnappy, "deflate", (VALUE (*)(...))snappy_deflate, -1);
    rb_define_singleton_method(rb_mSnappy, "inflate", (VALUE (*)(...))snappy_inflate, -1);

    rb_define_singleton_method(rb_mSnappy, "compress", (VALUE (*)(...))snappy_deflate, -1);
    rb_define_singleton_method(rb_mSnappy, "uncompress", (VALUE (*)(...))snappy_inflate, -1);
}
}
