require 'spec_helper'

describe Ferenc::Yss::Ad do
  describe '#label' do
    before do
      @ad_group = double label: 'Hoge', ads: []
    end

    it 'returns group label with number' do
      @ad = subject
      @ad.ad_group = @ad_group
      @ad_group.ads.replace [@ad]
      expect(@ad.label).to eq 'Hoge1'

      @ad_group.ads.replace [nil, @ad]
      expect(@ad.label).to eq 'Hoge2'
    end
  end
end
