require "open-uri"

module NationalBankOfRomania
  class InvalidCache < StandardError ; end
  class Cache
    attr_reader :url

    def initialize(url)
      @url = url
    end

    def save(path_to_file)
      raise InvalidCache unless path_to_file

      File.open(path_to_file, "w") do |file|
        io = open(url) ;
        io.each_line {|line| file.puts line}
      end
    end
  end
end
