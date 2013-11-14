require_relative '../spec_helper'



describe KnifeJoyent::Pricing::Config do
  context "URL Scraper" do

    let(:config) { KnifeJoyent::Pricing::Config.new() }

    let(:prices) { { "g3-standard-48-smartos" => 1.536,
                     "g3-standard-0.625-smartos" => 0.02 } }

    def verify
      prices.keys.each do |flavor|
        config[flavor].should eql(prices[flavor])
      end
    end

    it "should load pricing configuration hash from Joyent Website" do
      config.from_uri
      verify
    end

  end
end
