require "money"
module NationalBankOfRomania

  class Bank < ::Money::Bank::VariableExchange
    attr_accessor :last_updated

    RATES_URL = "http://www.bnro.ro/nbrfxrates.xml"
    CURRENCIES = %w(AED AUD BGN BRL CAD CHF CNY CZK DKK EGP EUR GBP HUF INR JPY
                    KRW MDL MXN NOK NZD PLN RSD RUB SEK TRY UAH USD ZAR)

    def save_rates(path_to_file)
      cache.save(path_to_file)
    end

    def update_rates(path_to_file = nil)
      exchange_rates(path_to_file).each do |rate|
        next unless CURRENCIES.include?(rate[:currency])
        add_rate("RON", rate[:currency], rate[:value])
      end

      add_rate("RON", "RON", 1)
      @last_updated = Time.now
    end

    def exchange(cents, from_currency, other_currency)
      from_currency = Money.new(cents, from_currency)
      other_currency = Money::Currency.wrap(other_currency)
      exchange_with(from_currency, other_currency)
    end

    def parser
      @parser ||= Parser.new(RATES_URL)
    end

    def cache
      @cache ||= Cache.new(RATES_URL)
    end

    private
      def exchange_rates(path_to_file = nil)
        parser.records(path_to_file)
      end
  end
end

