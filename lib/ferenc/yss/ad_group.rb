module Ferenc
  class Yss
    class AdGroup
      include ActiveModel::Model
      ATTRIBUTES = %i(campaign words budget ads)
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

      def display io
        i = 0
        self.ads.each do |ad|
          io << "#{i += 1}: #{ad.keyword}".bold << "\n"
          io << ad.title.blue.underline << "\n"
          io << ad.desc1 << "\n"
          io << ad.desc2 << "\n"
          io << ad.display_url.green << "\n\n"
        end
      end

      def valid?
        @ads && self.errors.blank?
      end

      def errors
        @errors ||= @ads && @ads.reject(&:valid?)
      end
    end
  end
end
