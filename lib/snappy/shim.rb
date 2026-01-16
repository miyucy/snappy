# frozen_string_literal: true

module Snappy
  module_function

  def set_encoding(io)
    io.set_encoding Encoding::ASCII_8BIT
    io
  end
end
