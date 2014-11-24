require 'ferenc/yss/campaign'
require 'ferenc/yss/ad'

module Ferenc
  class Yss
    attr_accessor :config, :elements

    class CampaignGenerator
      attr_reader :campaign, :mixer
      def initialize yss, attrs
        @yss = yss
        @campaign = yss.campaign(attrs.slice(*Campaign::ATTRIBUTES))
        @campaign.starts_on = Date.today.strftime('%Y/%m/%d')
        @ad_attrs = attrs[:ad] || {}
        @element_keys = attrs[:elements].try(:map, &:to_sym) ||  yss.elements.keys
      end

      def ads
        @mixer = Mixer.new(
          elements: @yss.elements.slice(*@element_keys),
          vocabularies: @yss.vocabularies,
        )
        @mixer.mix do |words, combo|
          generator = AdGenerator.new @yss, @ad_attrs, words, combo
          ad = generator.ad
          ad.campaign = @campaign
          ad.words = words
          %w(title desc1 desc2).each do |key|
            if (text = ad.send(key)).present?
              ad.send("#{key}=", @mixer.composer.fit(text, Ad.length_for(key)))
            end
          end
          ad.display_url ||= @campaign.domain
          ad.link_url ||= "http://#{@campaign.domain}/#{combo[0].to_param}.html"
          yield generator if block_given?
          ad
        end
        @campaign.ads = @mixer.products
      end
    end

    class AdGenerator
      attr_reader :ad, :words, :combo
      def initialize yss, attrs, words, combo
        @yss = yss
        @ad = yss.ad(attrs)
        @words = words
        @combo = combo
      end
    end

    def campaigns &proc
      config[:campaigns].map do |campaign_attrs|
        generator = CampaignGenerator.new self, campaign_attrs
        generator.ads(&proc)
        generator.campaign
      end
    end

    def campaign args = {}
      Campaign.new((config[:campaign] || {}).merge args)
    end

    def ad args = {}
      Ad.new((config[:ad] || {}).merge args)
    end

    def elements
      @elements ||= Yss.load_elements(@config[:elements] || {})
    end

    def vocabularies
      @vocabularies ||= @config[:vocabularies] || {}
    end

    class << self
      attr_accessor :current

      def load file
        yss = Yss.new
        yss.config = YAML.load_file(file).deep_symbolize_keys
        yss.elements = load_elements(yss.config[:elements])
        @current = yss
      end

      def load_elements elements
        elements.map do |key, args|
          if args.is_a? Hash
            [key, self.load_element(key, args)]
          else
            [key, args]
          end
        end.to_h
      end

      def load_element key, args
        struct = Struct.new(*args[:attributes].map(&:to_sym))
        elements = CSV.read(args[:csv]).select do |row|
          row.length == struct.members.length
        end.map do |row|
          struct.new(*row)
        end

        Element.const_set key.capitalize, struct
        struct.class_eval do
          define_singleton_method :all do
            elements
          end

          if args[:vocabularies]
            define_method :vocabularies do
              args[:vocabularies].map do |attr|
                self[attr]
              end.compact
            end
          end
        end

        elements
      end
    end
  end
end
