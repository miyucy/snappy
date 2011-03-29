#include "ruby.h"
#include "snappy.h"

static VALUE rb_mSnappy;
static ID    i_to_s;

static VALUE
snappy_deflate(VALUE self, VALUE source)
{
    snappy::string output;
    size_t  output_length;

    source = rb_funcall(source, i_to_s, 0);
    output_length = snappy::Compress(RSTRING_PTR(source), RSTRING_LEN(source), &output);

    return rb_str_new(output.data(), output_length);
}

static VALUE
snappy_inflate(VALUE self, VALUE source)
{
    snappy::string output;

    source = rb_funcall(source, i_to_s, 0);
    if (!snappy::IsValidCompressedBuffer(RSTRING_PTR(source), RSTRING_LEN(source)) ||
        !snappy::Uncompress(RSTRING_PTR(source), RSTRING_LEN(source), &output)) {
        rb_raise(rb_eRuntimeError, "Couldn't inflate");
    }

    return rb_str_new(output.data(), output.size());
}

extern "C" {
void Init_snappy()
{
    rb_mSnappy = rb_define_module("Snappy");
    rb_define_singleton_method(rb_mSnappy, "deflate", (VALUE (*)(...))snappy_deflate, 1);
    rb_define_singleton_method(rb_mSnappy, "inflate", (VALUE (*)(...))snappy_inflate, 1);

    rb_define_singleton_method(rb_mSnappy, "compress", (VALUE (*)(...))snappy_deflate, 1);
    rb_define_singleton_method(rb_mSnappy, "uncompress", (VALUE (*)(...))snappy_inflate, 1);

    i_to_s = rb_intern("to_s");
}
}
