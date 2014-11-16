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
      attr_accessor :current

      def load file
        yss = Yss.new
        yss.config = config = YAML.load_file(file)
        config['campaign'] ||= {}
        config['ad'] ||= {}

        yss.mixer = Mixer.new(
          elements: load_elements(config['elements']),
          vocabularies: config['vocabularies'],
          templates: config['templates']
        )
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
        args = args.symbolize_keys
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
