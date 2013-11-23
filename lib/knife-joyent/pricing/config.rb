require 'open-uri'
require 'nokogiri'

module KnifeJoyent
  module Pricing
    class Config < ::Hash
      JOYENT_URL = "http://www.joyent.com/products/compute-service/pricing"
      HOURS_PER_MONTH = 720

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

      def monthly_price_for_flavor(flavor_name)
        self[flavor_name] ? sprintf("$%.2f", self[flavor_name] * HOURS_PER_MONTH) : ""
      end

      def monthly_formatted_price_for_flavor(flavor, width = 10)
        self[flavor] ? formatted_price_for_value(self[flavor] * HOURS_PER_MONTH, width) : ""
      end

      def formatted_price_for_value(value, width = 10)
        sprintf("%#{width}s", currency_format(sprintf("$%.2f", value)))
      end

      # Returns string formatted with commas in the middle, such as "9,999,999"
      def currency_format string
         while string.sub!(/(\d+)(\d\d\d)/,'\1,\2'); end
         string
      end

      private

        def parse_html_document doc
          mappings = Hash.new
          specs = doc.css("ul.full-specs")
          specs.each do |ul|
            lis = ul.css("span").map(&:content)
            # grab last two <li> elements in each <ul class="full-spec"> block
            os, cost, flavor = lis[-3], lis[-2].gsub(/^\$/, ''), lis[-1]
            next if cost == "N/A"
            next if flavor =~ /kvm/ && os !~ /linux/i

            mappings[flavor] = cost.to_f
          end

          self.merge! mappings
        end
    end
  end
end

