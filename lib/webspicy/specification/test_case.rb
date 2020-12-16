module Webspicy
  class Specification
    class TestCase

      def initialize(raw)
        @raw = raw
        @counterexample = nil
      end
      attr_reader :service
      attr_reader :counterexample

      def bind(service, counterexample)
        @service = service
        @counterexample = counterexample
        self
      end

      def counterexample?
        !!@counterexample
      end

      def resource
        service.resource
      end

      def self.info(raw)
        new(raw)
      end

      def description
        @raw[:description]
      end

      def seeds
        @raw[:seeds]
      end

      def headers
        @raw[:headers] ||= {}
      end

      def metadata
        @raw[:metadata] ||= {}
      end

      def tags
        @raw[:tags] ||= []
      end

      def dress_params
        @raw.fetch(:dress_params){ true }
      end
      alias :dress_params? :dress_params

      def params
        @raw[:params] || {}
      end

      def body
        @raw[:body]
      end

      def file_upload
        @raw[:file_upload]
      end

      def located_file_upload
        file_upload ? file_upload.locate(resource) : nil
      end

      def expected
        @raw[:expected] || {}
      end

      def expected_content_type
        expected.fetch(:content_type){ 'application/json' }
      end

      def expected_status
        expected[:status]
      end

      def is_expected_status?(status)
        expected_status === status
      end

      def expected_error
        expected[:error]
      end

      def has_expected_error?
        !expected_error.nil?
      end

      def expected_headers
        expected[:headers] || {}
      end

      def has_expected_headers?
        !expected_headers.empty?
      end

      def assert
        @raw[:assert] || []
      end

      def has_assertions?
        !assert.empty?
      end

      def to_info
        @raw
      end

      def instrument(client)
        service.preconditions.each do |pre|
          pre.instrument(self, client)
        end
        service.postconditions.each do |post|
          post.instrument(self, client) if post.respond_to?(:instrument)
        end
      end

      def to_s
        description
      end

    end # class TestCase
  end # class Specification
end # module Webspicy
