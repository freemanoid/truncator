class UrlParser
  class << self
    URL_VALID_SYMBOLS = %Q{[#{Regexp.escape('!#$&-;=?-[]_~')}a-zA-Z0-9]}
    SEPARATOR = '...'

    def shorten_url(url, truncation_length = 42)
      url = url.dup
      unless ordinary_hostname?(url)
        if url[-1] != '/'
          # truncate all parameter except the first
          url[url.index('&')..-1] = '...'
        end
        return url
      end

      url.sub!(/\Ahttp:\/\//, '') # remove http protocol
      url.gsub(/\/{2,}/, '/') # replace multiple slashes by one
      url.chomp!('/') # remove slash from the end
      return url if valid_length?(url.length, truncation_length)

      if !has_path?(url)
        url = truncate(url, truncation_length)
        return url
      end

      if params_exists?(url)
        if invalid_length?(hostname(url).length, truncation_length) and last_directory(url).length > truncation_length
          url = truncate_last_directory(url, truncation_length)
        elsif valid_length?(url.length - last_directory(url).length, truncation_length) or !has_dirs?(url)
          url = truncate(url, truncation_length)
        end
      else
        if valid_length?(hostname(url).length, truncation_length)
          url = truncate_by_shortest(url, truncation_length)
        else
          url = truncate_all_directories(url)
          url = truncate_last_directory(url, truncation_length)
        end
      end

      url
    end

    private
      ## FIXME: add to String#truncate
      def truncate(str, length)
        str = str.dup
        if str.length > length
          str[(length - SEPARATOR.length)..-1] = SEPARATOR
        end
        str
      end

      def ordinary_hostname?(url)
        if url.start_with?('https://')
          # https
          false
        elsif url =~ /^http[s]?:\/\/[a-zA-Z\d.]+:\d{1,5}\//
          # has port
          false
        elsif url.start_with?('ftp://')
          # ftp
          false
        elsif url =~ /^http:\/\/[a-zA-Z\d]+:[a-zA-Z\d]+@[a-zA-Z\d.]+\//
          # with credentials
          false
        else
          true
        end
      end

      def hostname(url)
        url[0..(url.index('/') - 1)]
      end

      def valid_length?(url_length, truncation_length)
        url_length <= truncation_length
      end

      def invalid_length?(url_length, truncation_length)
        !valid_length?(url_length, truncation_length)
      end

      # Check if url has query parameters
      def params_exists?(url)
        valid_symbols_before_params = URL_VALID_SYMBOLS.dup.tap { |r| r[-1] = '.\/]' }
        !!(url =~ /^#{valid_symbols_before_params}+\?(#{URL_VALID_SYMBOLS}+)/)
      end

      def params(url)
        valid_symbols_before_params = URL_VALID_SYMBOLS.dup.tap { |r| r[-1] = '.\/]' }
        url.match(/^#{valid_symbols_before_params}+\?(#{URL_VALID_SYMBOLS}+)/)[1]
      end

      # Get the 'directories' of the link
      def directories(url)
        url.to_enum(:scan, /(?<=\/)(#{URL_VALID_SYMBOLS}+)(?=\/)/).map { Regexp.last_match }
      end

      def truncate_all_directories(url)
        first_slash = url.index('/')
        last_slash = url.rindex('/')
        url = url.dup
        url[first_slash..last_slash] = "/#{SEPARATOR}/"
        url
      end

      def last_directory(url)
        url[(url.rindex('/') + 1)..-1]
      end

      def truncate_last_directory(url, truncation_length)
        last_dir_begin = url.rindex('/') + 1
        last_dir = last_directory(url)
        url = url.dup
        url[last_dir_begin..-1] = truncate(last_dir, truncation_length)
        url
      end

      # If url has any 'dirs' this is suburls between '/'
      def has_dirs?(url)
        url.count('/') > 1
      end

      def has_path?(url)
        url.count('/') > 0
      end

      def truncate_by_shortest(url, target_length)
        url = url.dup
        dirs = directories(url)
        dirs_sorted = dirs.sort_by { |d| d.to_s.length }

        # Get the shortest dir and try to truncate the url by this dir and nexts
        dirs_sorted.each do |next_min_dir|
          current_dirs_length = 0
          current_dirs_count = 0
          dirs[dirs.index(next_min_dir)..-1].each do |dir|
            current_dirs_length += dir.to_s.length
            current_dirs_count += 1
            current_dirs_length_with_slashes = current_dirs_length + (current_dirs_count - 1) - SEPARATOR.length
            break if url.length - current_dirs_length_with_slashes <= target_length
          end
          current_dirs_length_with_slashes = current_dirs_length + (current_dirs_count - 1) - SEPARATOR.length

          if url.length - current_dirs_length_with_slashes <= target_length
            url[next_min_dir.begin(0)..
              (dirs[dirs.index(next_min_dir) + (current_dirs_count - 1)].end(0) - 1)] = SEPARATOR
            break
          end
        end
        url
      end
  end
end
