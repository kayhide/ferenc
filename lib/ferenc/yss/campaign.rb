module Ferenc
  class Yss
    class Campaign
      include ActiveModel::Model
      ATTRIBUTES = %i(name budget starts_on domain ads)
      attr_accessor(*ATTRIBUTES)

      def ads
        @ads ||= []
      end

      def label
        "#{self.name} (#{starts_on.strftime('%Y%m%d')})"
      end

      def to_csv
        rows = []
        rows << "キャンペーン名,広告グループ名,コンポーネントの種類,配信設定,配信状況,マッチタイプ,キーワード,カスタムURL,入札価格,広告名,タイトル,説明文1,説明文2,表示URL,リンク先URL,キャンペーン予算（日額）,キャンペーン開始日,デバイス,配信先,スマートフォン入札価格調整率（%）,広告タイプ,キャリア,優先デバイス,キャンペーンID,広告グループID,キーワードID,広告ID,エラーメッセージ"
        rows << "#{self.label},,キャンペーン,オフ,,,,,,,,,,,,#{self.budget},#{self.starts_on.strftime('%Y/%m/%d')},PC|タブレット|スマートフォン,すべて,0,,,,,,,,"
        self.ads.each do |ad|
          rows.concat ad.to_csv
        end
        rows.join("\n") + "\n"
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
