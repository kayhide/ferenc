module Ferenc
  class Yss
    class Ad
      include ActiveModel::Model
      attr_accessor :campaign
      attr_accessor :keyword, :budget, :title, :desc1, :desc2, :display_url, :link_url
      validates_presence_of :title, :desc1, :desc2
      validates_length_of :title, maximum: 15
      validates_length_of :desc1, maximum: 19
      validates_length_of :desc2, maximum: 19

      def to_csv rows = []
        rows << "#{self.campaign.name},#{self.group_name},広告グループ,オン,,,,,#{self.budget},,,,,,,,,,,,,,,,,,,"
        rows << "#{self.campaign.name},#{self.group_name},キーワード,オン,,部分一致,#{self.keyword},,#{self.budget},,,,,,,,,,,,,,,,,,,"
        rows << "#{self.campaign.name},#{self.group_name},広告,オン,,,,,,#{self.name},#{self.title},#{self.desc1},#{self.desc2},#{self.display_url},#{self.link_url},,,,,,テキスト（15・19-19）,,,,,,,"
      end

      def group_name
        self.name
      end

      def name
        self.keyword.gsub(/\s*/, '')
      end
    end
  end
end
