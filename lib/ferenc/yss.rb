require 'ferenc/yss/campaign'
require 'ferenc/yss/ad_group'
require 'ferenc/yss/ad'

module Ferenc
  class Yss
    attr_accessor :config, :elements

    class CampaignGenerator
      attr_reader :campaign, :mixer
      def initialize yss, attrs
        @yss = yss
        @attrs = attrs
      end

      def campaign
        if @campaign.nil?
          @campaign = Campaign.new(@attrs.slice(*Campaign::ATTRIBUTES))
          @campaign.starts_on = Date.today
          @element_keys = @attrs[:elements].try(:map, &:to_sym) || @yss.elements.keys
          @focused_element_keys = @attrs[:focused_elements].try(:map, &:to_sym) || []
          self.ads
        end
        @campaign
      end

      def ads
        @mixer = Mixer.new(
          elements: @yss.elements.slice(*@element_keys),
          vocabularies: @yss.vocabularies,
        )
        @composer = Composer.new @yss.vocabularies
        @mixer.mix do |words, combo|
          ad_group_attrs = @attrs[:ad_group] || {}
          ad_group = AdGroup.new(ad_group_attrs.slice(*AdGroup::ATTRIBUTES))
          ad_group.campaign = @campaign
          ad_group.words = focus words
          ad_group.display_url ||= @campaign.domain
          ad_group.path ||= @element_keys.map{|k| "<<#{k}>>"}.join('_') + '.html'
          path = composer_for(combo, :to_param).expand(ad_group.path).first
          ad_group.link_url ||= "http://#{@campaign.domain}/#{path}"
          ad_group.ads = ad_group_attrs[:ads].to_a.map do |ad_attrs|
            ad = Ad.new(ad_attrs.slice(*Ad::ATTRIBUTES))
            ad.ad_group = ad_group
            combo.members.each do |key|
              @composer.vocabularies[key] = combo[key].try(:vocabularies) || [combo[key].to_s]
            end
            %w(title desc1 desc2).each do |key|
              if (text = ad.send(key)).present?
                ad.send("#{key}=", @composer.fit(text, Ad.length_for(key)))
              end
            end
            ad
          end
          ad_group
        end
        @campaign.ad_groups = @mixer.products
      end

      def composer_for combo, method
        Composer.new combo.to_h.map{|k, v| [k, [v.try(method)]]}.to_h
      end

      def focused_element_indices
        @focused_element_indices ||= @focused_element_keys.map do |k|
          @element_keys.index k
        end
      end

      def focus words
        self.focused_element_indices.each do  |i|
          words[i] = "+#{words[i]}"
        end
        words
      end
    end

    def campaigns
      config[:campaigns].map do |attrs|
        g = CampaignGenerator.new self, attrs
        g.campaign
      end
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
                case attr
                when Symbol
                  self[attr]
                when String
                  attr
                end
              end.compact
            end
          else
            define_method :vocabularies do
              self.to_s
            end
          end
        end

        elements
      end
    end
  end
end
