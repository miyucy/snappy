module Snappy
  module_function

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
