require 'spec_helper'
module Webspicy
  class Configuration
    describe Scope, 'each_service' do

      let(:scope) {
        Scope.new(configuration)
      }

      let(:specification) {
        scope.each_specification.first
      }

      subject {
        scope.each_service(specification).to_a
      }

      context 'without any filter' do

        let(:configuration) {
          Configuration.new(restful_folder){|c|
            c.file_filter = /get.yml/
          }
        }

        it 'returns all services' do
          expect(subject.size).to eql(1)
        end
      end

      context 'with a service filter as a proc' do

        let(:configuration) {
          Configuration.new(restful_folder){|c|
            c.file_filter = /get.yml/
            c.service_filter = ->(s) {
              s.method == "POST"
            }
          }
        }

        it 'returns nothing' do
          expect(subject.size).to eql(0)
        end
      end

    end
  end
end
