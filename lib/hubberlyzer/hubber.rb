module Hubberlyzer
  class Hubber
    def initialize(data={})
      @hubber = data
    end

    def [](attribute)
      @hubber[attribute]
    end

    def profile
      @hubber["profile"]
    end

    def profile=(data)
      @hubber["profile"] = data
    end

    def stats
      @hubber["stats"]
    end

    def stats=(data)
      @hubber["stats"] = data
    end

    def raw
      @hubber
    end
  end
end