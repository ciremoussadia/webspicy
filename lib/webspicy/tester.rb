module Webspicy
  class Tester

    class FailFast < Exception; end

    def initialize(config)
      @config = Configuration.dress(config)
      @scope = nil
      @hooks = nil
      @client = nil
      @spec_file = nil
      @specification = nil
      @service = nil
      @test_case = nil
      @invocation = nil
      @reporter = default_reporter
    end
    attr_reader :config, :scope, :hooks, :client
    attr_reader :specification, :spec_file
    attr_reader :service, :test_case
    attr_reader :invocation, :result
    attr_reader :reporter

    def failfast?
      config.failfast
    end

    def default_reporter
      @reporter = Reporter::Composite.new
      #@reporter << Reporter::Progress.new
      @reporter << Reporter::Documentation.new
      @reporter << Reporter::Exceptions.new
      @reporter << Reporter::Summary.new
      @reporter << Reporter::ErrorCount.new
    end

    def call
      reporter.init(self)
      begin
        run_config
      rescue FailFast
      end
      reporter.report
      reporter.find(Reporter::ErrorCount).report
    end

  private

    def run_config
      config.each_scope do |scope|
        @scope = scope
        @hooks = Support::Hooks.for(scope.config)
        @client = scope.get_client
        reporter.before_all
        @hooks.fire_before_all
        reporter.before_all_done
        reporter.before_scope
        run_scope
        reporter.scope_done
        reporter.after_all
        @hooks.fire_after_all
        reporter.after_all_done
      end
    end

    def run_scope
      scope.each_specification_file do |spec_file|
        @specification = load_specification(spec_file)
        if @specification
          reporter.before_specification
          run_specification
          reporter.specification_done
          reporter.spec_file_done
        elsif failfast?
          raise FailFast
        end
      end
    end

    def load_specification(spec_file)
      @spec_file = spec_file
      reporter.before_spec_file
      Webspicy.specification(spec_file.load, spec_file, scope)
    rescue *PASSTHROUGH_EXCEPTIONS
      raise
    rescue Exception => e
      reporter.spec_file_error(e)
      nil
    end

    def run_specification
      scope.each_service(specification) do |service|
        @service = service
        reporter.before_service
        run_service
        reporter.service_done
      end
    end

    def run_service
      scope.each_testcase(service) do |test_case|
        @test_case = test_case
        reporter.before_test_case
        run_test_case
        reporter.test_case_done
      end
    end

    def run_test_case
      hooks.fire_around(test_case, client) do
        reporter.before_each
        hooks.fire_before_each(test_case, client)
        reporter.before_each_done

        reporter.before_instrument
        client.instrument(test_case)
        reporter.instrument_done

        reporter.before_invocation
        @invocation = client.call(test_case)
        reporter.invocation_done

        reporter.before_assertions
        check_invocation
        reporter.assertions_done

        reporter.after_each
        hooks.fire_after_each(test_case, @invocation, client)
        reporter.after_each_done

        raise FailFast if !result.success? and failfast?
      end
    end

    def check_invocation
      @result = Result.from(self)
    end

  end # class Tester
end # module Webspicy
require_relative 'tester/reporter'
require_relative 'tester/client'
require_relative 'tester/invocation'
require_relative 'tester/result'
require_relative 'tester/failure'
require_relative 'tester/assertions'
require_relative 'tester/asserter'
require_relative 'tester/file_checker'
