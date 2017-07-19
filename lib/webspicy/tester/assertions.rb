module Webspicy
  class Tester
    module Assertions

      class InvalidArgError < StandardError; end

      NO_ARG = Object.new

      def exists(target, path = NO_ARG)
        target = extract_path(target, path)
        not target.nil?
      end

      def notExists(target, path = NO_ARG)
        target = extract_path(target, path)
        target.nil?
      end

      def empty(target, path = NO_ARG)
        target = extract_path(target, path)
        respond_to!(target, :empty?).empty?
      end

      def notEmpty(target, path = NO_ARG)
        not empty(target, path)
      end

      def size(target, path, expected = NO_ARG)
        path, expected = '', path if expected == NO_ARG
        target = extract_path(target, path)
        respond_to!(target, :size).size == expected
      end

      def idIn(target, path, expected = NO_ARG)
        path, expected = '', path if expected == NO_ARG
        target = extract_path(target, path)
        ids = an_array(target).map do |tuple|
          respond_to!(tuple, :[])[:id]
        end
        ids.to_set == expected.to_set
      end

      def idNotIn(target, path, expected = NO_ARG)
        path, expected = '', path if expected == NO_ARG
        target = extract_path(target, path)
        ids = an_array(target).map do |tuple|
          respond_to!(tuple, :[])[:id]
        end
        (ids.to_set & expected.to_set).empty?
      end

      def idFD(target, path, id, expected = NO_ARG)
        if expected == NO_ARG
          expected = id
          id, path = path, ''
        end
        target = extract_path(target, path)
        found = an_array(target).find{|t| t[:id] == id }
        expected.keys.all?{|k|
          value_equal(expected[k], found[k])
        }
      end

      def pathFD(target, path, expected)
        target = extract_path(target, path)
        expected.keys.all?{|k|
          value_equal(expected[k], target[k])
        }
      end

    private

      def extract_path(target, path = NO_ARG)
        return target if path.nil? or path==NO_ARG or path.empty?
        return nil unless target.is_a?(Hash)
        path.split('/').inject(target) do |memo,key|
          memo && (memo.is_a?(Array) ? memo[key.to_i] : memo[key.to_sym])
        end
      end

      def respond_to!(target, method)
        unless target.respond_to?(method)
          raise InvalidArgError, "Expecting instance responding to #{method}"
        end
        target
      end

      def an_array(target)
        target.is_a?(Array) ? target : [target]
      end

      def value_equal(exp, got)
        case exp
        when Hash
          exp.all?{|(k,v)| got[k] == v }
        else
          exp == got
        end
      end

    end # module Assertions
  end # class Tester
end # module Webspicy
