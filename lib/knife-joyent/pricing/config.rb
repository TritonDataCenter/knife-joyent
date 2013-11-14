require 'open-uri'
require 'nokogiri'

module KnifeJoyent
  module Pricing
    class Config < ::Hash
      JOYENT_URL = "http://www.joyent.com/products/compute-service/pricing"

      def initialize
        super
        from_uri
      end

      def from_uri(uri = JOYENT_URL)
        parse_html_document Nokogiri::HTML(open(uri))
      rescue
      end

      def from_html_file filename
        parse_html_document Nokogiri::HTML(File.read(filename))
      end

      private

        def parse_html_document doc
          mappings = Hash.new
          specs = doc.css("ul.full-specs")
          specs.each do |ul|
            lis = ul.css("span").map(&:content)
            # grab last two <li> elements in each <ul class="full-spec"> block
            cost, flavor = lis[-2].gsub(/^\$/, ''), lis[-1]
            next if cost == "N/A"
            mappings[flavor] = cost.to_f
          end

          self.merge! mappings
        end
    end
  end
end
