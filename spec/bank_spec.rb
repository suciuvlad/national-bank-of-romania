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

  context "#exchange" do
    it "calls 'exchange_with' with the correct params" do
      @bank.update_rates(@feed)

      from = Money.new(100, "RON")
      to = Money::Currency.wrap("USD")
      money = double(:cents => 324, :currency => "USD")

      @bank.should_receive(:exchange_with).with(from, to).and_return(money)
      @bank.exchange(100, "RON", "USD")
    end

    it "exchanges currencies based on the base currency" do
      @bank.update_rates(@feed)

      @bank.exchange(100, "EGP", "MDL").to_f.should ===
        @exchange_rates["mixed_currencies"]["EGP_TO_MDL"]
      @bank.exchange(100, "EUR", "USD").to_f.should ===
        @exchange_rates["mixed_currencies"]["EUR_TO_USD"]
    end
  end

  context "#exchange_with" do
    it "returns the same currency if the to_currency is the same" do
      @bank.update_rates(@feed)
      m1 = Money.new(1000, "RON")

      @bank.exchange_with(m1, "RON").should == m1
    end

    it "returns the correct exchange rates" do
      @bank.update_rates(@feed)
      NationalBankOfRomania::Bank::CURRENCIES.each do |currency|
        m1 = Money.new(100, "RON")
        subunit = Money::Currency.wrap(currency).subunit_to_unit
          .to_s.scan(/0/).count
        value = BigDecimal.new(@exchange_rates["currencies"][currency].to_s)
          .truncate(subunit.to_i).to_f

        @bank.exchange_with(m1, currency).to_f.should == value
      end
    end
  end

end
