# NationalBankOfRomania


This gem provides the ability to download the exchange rates from the National Bank of Romania and it is compatible with the [money gem](https://github.com/RubyMoney/money/).

## Installation

Add this line to your application's Gemfile:

    gem 'national_bank_of_romania'    

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install national_bank_of_romania

## Dependencies

* nokogiri
* money

## Usage

You can use it together with the money gem. The money gem accepts an exchange bank object:

	ro_bank = NationalBankOfRomania::Bank.new
	
	# scrapes bnr.ro for the current rates
	ro_bank.update_rates
	
	# change the default bank
	Money.default_bank = ro_bank
	
	# exchange API examples
	Money.us_dollar(100).exchange_to("CAD")
	# or
	money1 = Money.new(100, "RON")
	money1.exchange_to("RON")

Calling ```update_rates``` will automatically populate the object with the rates from the National Bank of Romania's official website. 

The gem is a wrapper around the money library therefore you can simply use it like so:

	ro_bank = NationalBankOfRomania::Bank.new
	
	# scrapes bnr.ro for the current rates
	ro_bank.update_rates
	
	# exchange 100 RON to USD
	ro_bank.exchange(100, "RON", "USD")
	
### Performance Considerations

The currency rates are updated once a day hence that it makes sense to save them in a file.

	# saves the rates in a specified location
	ro_bank = NationalBankOfRomania::Bank.new
	ro_bank.save_rates("/path/to/rates.xml")
	
	# calling update_rates with a path to load the rates from
	ro_bank.update_rates("/path/to/rates.xml")
	

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Special Thanks

NationalBankOfRomania was inspired by [eu_central_bank](https://github.com/RubyMoney/eu_central_bank) and they would both not be possible without the popular [money gem](https://github.com/RubyMoney/money/).
