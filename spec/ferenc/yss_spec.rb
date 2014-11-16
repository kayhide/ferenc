require 'spec_helper'

describe Ferenc::Yss do
  describe '.load' do
    it 'loads config' do
      file = 'spec/fixtures/yss.yml'
      yss = Ferenc::Yss.load file

      expect(yss.mixer.elements).to eq({
        'location' => %w(Tokyo Kyoto),
        'facility' => %w(Library School)
      })
      expect(yss.mixer.vocabularies).to eq({
        'size' => %w(small big),
        'food' => %w(apple banana)
      })
      expect(yss.mixer.templates).to eq({
        'good' => 'my <<size>> <<food>> is good.',
        'bad' => 'your <<size>> <<food>> is bad.'
      })
    end
  end

  describe '#campaign' do
    before do
      @yss = subject
      @yss.config = {
        'campaign' => {name: 'Campaign', budget: 1234}
      }
    end

    it 'creates campaign with cofig' do
      campaign = @yss.campaign
      expect(campaign.name).to eq 'Campaign'
      expect(campaign.budget).to eq 1234
    end

    it 'overwrites by args' do
      campaign = @yss.campaign name: 'Overwritten'
      expect(campaign.name).to eq 'Overwritten'
    end
  end

  describe '#ad' do
    before do
      @yss = subject
      @yss.config = {
        'ad' => {keyword: 'Keyword', budget: 123}
      }
    end

    it 'creates ad with cofig' do
      ad = @yss.ad
      expect(ad.keyword).to eq 'Keyword'
      expect(ad.budget).to eq 123
    end

    it 'overwrites by args' do
      ad = @yss.ad keyword: 'Overwritten'
      expect(ad.keyword).to eq 'Overwritten'
    end

    describe 'when title, desc1 and desc2 are set' do
      before do
        @yss.config['ad'].merge!({
          title: '<<location>>',
          desc1: '<<location>> is good.',
          desc2: '<<location>> is nice.',
        })
      end

      it 'sets composed texts' do
        @yss.mixer = Ferenc::Mixer.new vocabularies: {'location' => %w(Tokyo)}
        ad = @yss.ad
        expect(ad.title).to eq 'Tokyo'
        expect(ad.desc1).to eq 'Tokyo is good.'
        expect(ad.desc2).to eq 'Tokyo is nice.'
      end
    end
  end
end
