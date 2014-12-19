module Ferenc
  class Yss
    class AdGroup
      include ActiveModel::Model
      ATTRIBUTES = %i(campaign ads words budget display_url link_url path)
      attr_accessor(*ATTRIBUTES)

      def ads
        @ads ||= []
      end

      def label
        self.keyword.gsub(/\s*/, '')
      end

      def keyword
        self.words.join(' ')
      end

      def to_csv
        [
          "#{self.campaign.label},#{self.label},広告グループ,オン,,,,,#{self.budget},,,,,,,,,,,,,,,,,,,",
          "#{self.campaign.label},#{self.label},キーワード,オン,,部分一致,#{self.keyword},,一括入札,,,,,,,,,,,,,,,,,,,",
        ].concat ads.map(&:to_csv).flatten
      end
    end
  end
end
