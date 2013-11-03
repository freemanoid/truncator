require 'active_support/core_ext/class/attribute_accessors'

class String
  cattr_accessor :separator
end

module Truncator
  module ExtendedString
    refine String do
      def truncate!(length, separator = nil)
        separator ||= self.separator
        fail ArgumentError, 'Separator should be present. Pass it via last argument or set globally String.separator=' unless separator
        if self.length > length
          self[(length - separator.length)..-1] = separator
        end
        self
      end

      def truncate(*args)
        self.dup.truncate!(*args)
      end

      def valid_length?(valid_length)
        self.length <= valid_length
      end

      def invalid_length?(*args)
        not valid_length?(*args)
      end
    end
  end
end
