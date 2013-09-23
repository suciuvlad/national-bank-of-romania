require "nokogiri"

module NationalBankOfRomania
  class Parser
    attr_reader :url

    def initialize(url)
      @url = url
      @records = nil
    end

    def records(cache)
      @records = doc(cache).root.elements[1].elements[2].elements
      formatted_records
    end

    def date(cache)
      date = doc(cache).root.elements[0].elements[1].children[0].text
    end

    def doc(cache)
      source = !!cache ? cache : url
      doc = Nokogiri::XML(open(source))
    end

    private
      def formatted_records
        @records.map do |row|
          { :currency => row.attribute("currency").value, :value => row.text.to_f }
        end
      end
  end
end
