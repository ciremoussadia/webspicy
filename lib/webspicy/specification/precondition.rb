module Webspicy
  class Specification
    module Precondition

      def self.match(service, pre)
      end

      def instrument(test_case, client)
      end

      def counterexamples(service)
        []
      end

    end # module Precondition
  end # class Specification
end # module Webspicy
require_relative 'precondition/global_request_headers'
