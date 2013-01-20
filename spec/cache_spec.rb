require "spec_helper"
require "cache"

describe "cache" do

  before(:each) do
    @bank = NationalBankOfRomania::Bank.new
    @feed = File.expand_path(File.dirname(__FILE__) + '/fixtures/nbrfxrates.xml')
    @tmp = File.expand_path(File.dirname(__FILE__) + '/fixtures/tmp_nbrfxrates.xml')

    @bank.stub(:open).and_return(File.read(@feed))
  end

  after(:each) do
    if File.exists? @tmp
      File.delete @tmp
    end
  end

  context "#save" do
    it "the xml file given a file path" do
      @bank.save_rates(@tmp)
      File.exists?(@tmp).should === true
    end

    it "raise an error if an invalid path is given" do
      lambda { @bank.save_rates(nil) }.should raise_exception
    end
  end


end
