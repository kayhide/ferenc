module Ferenc
  class Mixer
    attr_accessor :elements, :vocabularies
    attr_reader :products

    def initialize args = {}
      @elements = args[:elements] || {}
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
        @products << yield(args.map(&:second), combo.new(*args.map(&:last)))
      end
    end

    def valid?
      @products && self.errors.blank?
    end

    def errors
      @errors ||= @products && @products.reject(&:valid?)
    end
  end
end
