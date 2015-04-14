module Asana
  module Resources
    # Public: Represents a collection of Asana resources.
    class Collection
      include Enumerable

      def initialize(elements, client:)
        @elements = elements
        @client   = client
      end

      def each(&block)
        if block
          @elements.each(&block)
        else
          @elements.each
        end
      end

      def to_s
        "#<Asana::Collection [#{@elements.map(&:inspect).join(', ')}]>"
      end

      alias_method :inspect, :to_s
    end
  end
end
