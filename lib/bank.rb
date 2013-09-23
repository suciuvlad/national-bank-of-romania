require "money"
module NationalBankOfRomania

  class Bank < ::Money::Bank::VariableExchange
    attr_accessor :last_updated, :rates_updated_at

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
      @rates_updated_at = Time.parse(parser.date(path_to_file))
    end

    def exchange_with(from, to_currency)
      return from if same_currency?(from.currency, to_currency)

      unless rate = get_rate(from.currency, to_currency)
        from_base_rate = BigDecimal.new(get_rate("RON", from.currency).to_s)
        to_base_rate = BigDecimal.new(get_rate("RON", to_currency).to_s)

        rate = from_base_rate / to_base_rate
      end
      _to_currency_  = Money::Currency.wrap(to_currency)

      cents = BigDecimal.new(from.cents.to_s) /
        (BigDecimal.new(from.currency.subunit_to_unit.to_s) /
         BigDecimal.new(_to_currency_.subunit_to_unit.to_s))

      ex = cents * BigDecimal.new(rate.to_s)
      ex = ex.to_f
      ex = if block_given?
              yield ex
            elsif @rounding_method
              @rounding_method.call(ex)
            else
              ex.to_s.to_i
            end
      Money.new(ex, _to_currency_)
    end

    def exchange(cents, from_currency, to_currency)
      from_currency = Money.new(cents, from_currency)
      to_currency = Money::Currency.wrap(to_currency)
      exchange_with(from_currency, to_currency)
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

