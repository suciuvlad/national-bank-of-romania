require "spec_helper"
require "national_bank_of_romania"

describe "Bank" do

  before(:each) do
    @bank = NationalBankOfRomania::Bank.new
    @feed = File.expand_path(File.dirname(__FILE__) + '/fixtures/nbrfxrates.xml')
    @tmp = File.expand_path(File.dirname(__FILE__) + '/fixtures/tmp_nbrfxrates.xml')

    @yml = File.expand_path(File.dirname(__FILE__) + '/fixtures/exchange_rates.yml')
    @exchange_rates = YAML.load_file(@yml)

    @bank.stub(:open).and_return(File.read(@feed))
  end

  it "calls 'save' on the Cache" do
    @bank.cache.should_receive(:save).with(@tmp)
    @bank.save_rates(@tmp)
  end

  context "#update_rates" do
    it "from BNR unless a local feed is given" do
      @bank.update_rates

      NationalBankOfRomania::Bank::CURRENCIES.each do |currency|
        @bank.get_rate("RON", currency).should > 0
      end
    end

    it "from cache if a local feed is given" do
      @bank.update_rates(@feed)

      NationalBankOfRomania::Bank::CURRENCIES.each do |currency|
        @bank.get_rate("RON", currency).should > 0
      end
    end
  end

  it "should set last_updated when the rates are updated" do
    bank1 = @bank.last_updated
    @bank.update_rates(@feed)

    bank2 = @bank.last_updated
    @bank.update_rates(@feed)

    bank3 = @bank.last_updated

    bank1.should_not eq(bank2)
    bank2.should_not eq(bank3)
  end

  it "should return the correct exchange rates using exchange" do
    @bank.update_rates(@feed)

    NationalBankOfRomania::Bank::CURRENCIES.each do |currency|
      subunit = Money::Currency.wrap(currency).subunit_to_unit.to_s.scan(/0/).count
      value = BigDecimal.new(@exchange_rates["currencies"][currency].to_s).truncate(subunit.to_i).to_f
      @bank.exchange(100, "RON", currency).to_f.should == value
    end
  end

end
