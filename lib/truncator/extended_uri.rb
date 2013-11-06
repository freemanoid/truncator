require 'uri'

module Truncator
  module ExtendedURI
    refine URI::Generic do
      def ordinary_hostname?
        if %w(https ftp).include?(self.scheme) || self.userinfo || self.port_defined?
          false
        else
          true
        end
      end

      def path_blank?
        ['', nil, '/'].include? self.path
      end

      def paths
        self.path.split('/').delete_if(&:empty?)
      end

      def paths=(paths_array)
        _path = paths_array.join('/')
        # We should insure that we have leading '/'
        _path.prepend('/') unless _path[0] == '/'
        self.path = _path
        self
      end

      def query_parameters
        URI.decode_www_form(self.query)
      end

      def query_parameters=(params)
        self.query = URI.encode_www_form(params)
      end

      ##App specific
      def special_format
        str = self.to_s
        if ordinary_hostname?
          str.sub!(/\Ahttp:\/\//, '') # remove http protocol
          str.gsub(/\/{2,}/, '/') # replace multiple slashes by one
          str.chomp!('/') # remove slash from the end
        end
        str
      end

      private
        def port_defined?
          port = self.port
          self.to_s.include? ":#{port}"
        end
    end
  end
end
