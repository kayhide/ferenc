require 'ferenc/yss/campaign'
require 'ferenc/yss/ad'

module Ferenc
  class Yss
    attr_accessor :config, :mixer

    def campaign args = {}
      Campaign.new(config['campaign'].merge args)
    end

    def ad args = {}
      ad = Ad.new(config['ad'].merge args)
      %w(title desc1 desc2).each do |key|
        if (text = ad.send(key)).present?
          ad.send("#{key}=", @mixer.composer.fit(text, Ad.length_for(key)))
        end
      end

      ad
    end

    class << self
      def load file
        yss = Yss.new
        yss.config = config = YAML.load_file(file)
        config['campaign'] ||= {}
        config['ad'] ||= {}

        yss.mixer = Mixer.new config.slice('elements', 'vocabularies', 'templates')

        yss
      end
    end
  end
end
