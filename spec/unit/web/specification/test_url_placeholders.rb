require "spec_helper"
module Webspicy
  module Web
    describe Specification, "url_placeholders" do

      it 'returns an empty array on none' do
        r = Specification.new(url: "/test/a/url")
        expect(r.url_placeholders).to eq([])
      end

      it 'returns all placeholders' do
        r = Specification.new(url: "/test/{foo}/url/{bar}")
        expect(r.url_placeholders).to eq(["foo", "bar"])
      end

      it 'returns all placeholders expr' do
        r = Specification.new(url: "/test/{foo.id}/url/{bar}")
        expect(r.url_placeholders).to eq(["foo.id", "bar"])
      end

    end
  end
end
