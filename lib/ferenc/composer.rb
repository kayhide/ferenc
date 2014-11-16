module Ferenc
  class Composer
    attr_accessor :vocabularies

    def initialize vocabularies = {}
      @vocabularies = vocabularies.clone
    end

    def fit text, max_length
      self.expand(text).select do |str|
        str.length <= max_length
      end.first
    end

    def expand text
      tokens = text.scan(/(<<+([^<>]+)>>+|[^<>]+)/).each_with_index.map do |m, i|
        if m.last
          Token.new i, @vocabularies[m.last], m.first.count('<')
        else
          Token.new i, [m.first], 0
        end
      end.sort_by do |token|
        [-token.weight, token.place]
      end

      [nil].product(*tokens.map(&:values)).map do |_, *strs|
        strs.zip(tokens).sort_by do |str, token|
          token.place
        end.map(&:first).join
      end
    end

    Token = Struct.new :place, :values, :weight
  end
end
