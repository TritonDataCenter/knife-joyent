require_relative '../spec_helper'


describe KnifeJoyent::Pricing::Config do
  let(:config) { KnifeJoyent::Pricing::Config.new() }

  let(:prices) { {"g3-standard-48-smartos" => 1.536,
                  "g3-standard-0.625-smartos" => 0.02,
                  "g3-standard-30-kvm" => 0.960} }

  def verify
    prices.keys.each do |flavor|
      expect(config[flavor]).to eql(prices[flavor])
    end
  end

  it "should load pricing configuration hash from Joyent Website" do
    config.from_uri
    verify
  end

  context "#monthly_price_for_flavor" do
    it "should return properly formatted monthly price" do
      expect(config.monthly_price_for_flavor "g3-standard-0.625-smartos").to eql("$14.40")
      expect(config.monthly_price_for_flavor "g3-standard-30-kvm").to eql("$691.20")
    end
  end
  context "#monthly_formatted_price_for_flavor" do
    it "should return properly formatted monthly price" do
      expect(config.monthly_formatted_price_for_flavor "g3-standard-48-smartos").to eql(" $1,105.92")
    end
    it "should return blank when no match was found" do
      expect(config.monthly_formatted_price_for_flavor "asdfkasdfasdlfkjasl;dkjf").to eql("")
    end
  end
  context "#formatted_price_for_value" do
    it "should return properly formatted price" do
      expect(config.formatted_price_for_value 24566.34).to eql("$24,566.34")
      expect(config.formatted_price_for_value 4566.34).to eql(" $4,566.34")
    end
  end
end
