module Truncator
  module ExtendedArray
    refine Array do

      # Generate all possible combinations of sequential elements
      # Example: [1, 2, 3].sequences #=> [[1], [2], [3], [1, 2], [2, 3], [1, 2, 3]]
      def sequences
        self.each_index.inject([]) { |result, i| self.each_cons(i + 1) { |cons| result << cons }; result }
      end
    end
  end
end
