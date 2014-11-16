module Ferenc
  class Mixer
    attr_accessor :composer, :elements, :vocabularies, :templates
    attr_reader :products

    def initialize
      @composer = Composer.new
      @elements = {}
      @vocabularies = {}
      @templates = {}
    end

    def mix
      @products = []
      @errors = nil
      expanded_elements = @elements.map do |key, elms|
        elms.map do |elm|
          self.vocabularies_for(elm).map do |word|
            [key, word, elm]
          end
        end.inject(&:+)
      end

      [nil].product(*expanded_elements).map do |_, *args|
        self.composer.vocabularies = self.vocabularies.clone
        args.each do |key, word, elm|
          self.composer.vocabularies[key] = vocabularies_for(elm)
        end
        @products << yield(args.map{|_, word, _| word}, *args.map(&:last))
      end
    end

    def vocabularies_for obj
      (obj.respond_to?(:vocabularies) && obj.vocabularies) || [obj]
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
