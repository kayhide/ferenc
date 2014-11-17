module Ferenc
  class Mixer
    attr_accessor :elements, :vocabularies, :templates
    attr_reader :products

    def initialize args = {}
      args = args.symbolize_keys
      @elements = args[:elements] || {}
      @vocabularies = args[:vocabularies] || {}
      @templates = args[:templates] || {}
    end

    def mix
      @products = []
      @errors = nil
      expanded_elements = @elements.map do |key, elms|
        elms.map do |elm|
          [key, elm.to_s, elm]
        end
      end

      combo = Struct.new(*@elements.keys.map(&:to_sym))
      [nil].product(*expanded_elements).map do |_, *args|
        args.each do |key, word, elm|
          self.composer.vocabularies[key] = elm.try(:vocabularies) || [elm.to_s]
        end
        @products << yield(args.map(&:second), combo.new(*args.map(&:last)))
      end
    end

    def composer
      @composer ||= Composer.new self.vocabularies
    end

    def init_composer
      @composer = nil
      self.composer
    end

    def valid?
      @products && self.errors.blank?
    end

    def errors
      @errors ||= @products && @products.reject(&:valid?)
    end

    def compose key, max_length
      self.composer.fit(self.templates[key.to_s], max_length)
    end
  end
end
