module Ferenc
  class Yss
    class Ad
      TITLE_LENGTH = 15
      DESC1_LENGTH = 19
      DESC2_LENGTH = 19

      include ActiveModel::Model
      ATTRIBUTES = %i(ad_group title desc1 desc2 display_url link_url path)
      attr_accessor(*ATTRIBUTES)
      validates_presence_of :title, :desc1, :desc2
      validates_length_of :title, maximum: TITLE_LENGTH
      validates_length_of :desc1, maximum: DESC1_LENGTH
      validates_length_of :desc2, maximum: DESC2_LENGTH

      def to_csv
        [
          "#{self.campaign.label},#{self.ad_group.label},広告,オン,,,,,,#{self.label},#{self.title},#{self.desc1},#{self.desc2},#{self.display_url},#{self.link_url},,,,,,テキスト（15・19-19）,,,,,,,"
        ]
      end

      def campaign
        self.ad_group.campaign
      end

      def label
        i = self.ad_group.ads.index self
        "#{self.ad_group.label}#{i + 1}"
      end

      def keyword
        self.ad_group.words.join(' ')
      end

      class << self
        def length_for key
          self.const_get "#{key.upcase}_LENGTH"
        end
      end
    end
  end
end
