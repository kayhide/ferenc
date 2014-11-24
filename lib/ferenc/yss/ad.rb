module Ferenc
  class Yss
    class Ad
      TITLE_LENGTH = 15
      DESC1_LENGTH = 19
      DESC2_LENGTH = 19

      include ActiveModel::Model
      attr_accessor :campaign, :words
      attr_accessor :budget, :title, :desc1, :desc2, :display_url, :link_url
      validates_presence_of :title, :desc1, :desc2
      validates_length_of :title, maximum: TITLE_LENGTH
      validates_length_of :desc1, maximum: DESC1_LENGTH
      validates_length_of :desc2, maximum: DESC2_LENGTH

      def to_csv
        [
          "#{self.campaign.name},#{self.group_name},広告グループ,オン,,,,,#{self.budget},,,,,,,,,,,,,,,,,,,",
          "#{self.campaign.name},#{self.group_name},キーワード,オン,,部分一致,#{self.keyword},,#{self.budget},,,,,,,,,,,,,,,,,,,",
          "#{self.campaign.name},#{self.group_name},広告,オン,,,,,,#{self.name},#{self.title},#{self.desc1},#{self.desc2},#{self.display_url},#{self.link_url},,,,,,テキスト（15・19-19）,,,,,,,"
        ]
      end

      def group_name
        self.name
      end

      def name
        self.keyword.gsub(/\s*/, '')
      end

      def keyword
        self.words.join(' ')
      end

      class << self
        def length_for key
          self.const_get "#{key.upcase}_LENGTH"
        end
      end
    end
  end
end
