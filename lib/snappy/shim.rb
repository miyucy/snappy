# frozen_string_literal: true

module Snappy
  module_function

  if RUBY_VERSION[0..2] == "1.8"
    def set_encoding(io)
      io
    end

    def b(str)
      str
    end
  else
    def set_encoding(io)
      io.set_encoding Encoding::ASCII_8BIT
      io
    end

    if ::String.instance_methods.include? :b
      def b(str)
        str.b
      end
    else
      def b(str)
        str.force_encoding Encoding::ASCII_8BIT
      end
    end
  end
end
