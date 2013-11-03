using Truncator::ExtendedURI
using Truncator::ExtendedString

module Truncator
  class UrlParser
    class << self
      URL_VALID_SYMBOLS = %Q{[#{Regexp.escape('!#$&-;=?-[]_~')}a-zA-Z0-9]}
      SEPARATOR = '...'
      String.separator = SEPARATOR

      def shorten_url(uri, truncation_length = 42)
        uri = URI(uri)
        url = uri.to_s #FIXME: remove after refactoring
        if not uri.ordinary_hostname?
          if uri.query
            uri.query_parameters = [uri.query_parameters.first]
            return uri.to_s + SEPARATOR
          else
            return uri.to_s
          end
        end

        url.sub!(/\Ahttp:\/\//, '') # remove http protocol
        url.gsub(/\/{2,}/, '/') # replace multiple slashes by one
        url.chomp!('/') # remove slash from the end
        return url if url.valid_length?(truncation_length)

        if uri.path_blank? and not uri.query
          return url.truncate!(truncation_length)
        end

        if uri.query
          if hostname(url).invalid_length?(truncation_length) and uri.last_path_with_query.length > truncation_length
            url = truncate_last_directory(uri, truncation_length).special_format
          elsif url.valid_length?(truncation_length + uri.last_path_with_query.length) or not uri.path_blank?
            url.truncate!(truncation_length)
          end
        else
          if hostname(url).valid_length?(truncation_length)
            url = truncate_by_shortest(url, truncation_length)
          else
            uri = truncate_all_directories(uri)
            url = truncate_last_directory(uri, truncation_length).special_format
          end
        end

        url
      end

      private
        def hostname(url)
          url[0..(url.index('/') - 1)]
        end

        # Get the 'directories' of the link
        def directories(url)
          url.to_enum(:scan, /(?<=\/)(#{URL_VALID_SYMBOLS}+)(?=\/)/).map { Regexp.last_match }
        end

        def truncate_all_directories(uri)
          uri = uri.dup
          paths = uri.paths
          if paths.size > 1
            uri.paths = [SEPARATOR, paths.last]
          end
          uri
        end

        def truncate_last_directory(uri, truncation_length)
          uri = uri.dup
          last_path_with_query = uri.last_path_with_query
          uri.last_path_with_query = last_path_with_query.truncate(truncation_length)
          uri
        end

        def truncate_by_shortest(url, target_length)
          url = url.dup
          dirs = directories(url)
          dirs_sorted = dirs.sort_by { |d| d.to_s.length }

          # Get the shortest dir and try to truncate the url by this dir and next
          dirs_sorted.each do |next_min_dir|
            current_dirs_length = 0
            current_dirs_count = 0
            dirs[dirs.index(next_min_dir)..-1].each do |dir|
              current_dirs_length += dir.to_s.length
              current_dirs_count += 1
              current_dirs_length_with_slashes = current_dirs_length + (current_dirs_count - 1) - SEPARATOR.length
              if url.valid_length?(target_length + current_dirs_length_with_slashes)
                url[next_min_dir.begin(0)..(dirs[dirs.index(next_min_dir) + (current_dirs_count - 1)].end(0) - 1)] = SEPARATOR
                return url
              end
            end
          end
          url
        end
    end
  end
end
