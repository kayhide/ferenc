require 'spec_helper'

describe Ferenc::Yss do
  describe '.load' do
    it 'loads config' do
      file = 'spec/fixtures/yss.yml'
      yss = Ferenc::Yss.load file

      expect(yss.elements).to eq({
        location: %w(Tokyo Kyoto),
        facility: %w(Library School)
      })
      expect(yss.vocabularies).to eq({
        size: %w(small big),
        food: %w(apple banana)
      })
    end

    it 'sets current' do
      file = 'spec/fixtures/yss.yml'
      yss = Ferenc::Yss.load file
      expect(Ferenc::Yss.current).to eq yss
    end
  end

  describe '.load_elements' do
    it 'returns hash' do
      elements = Ferenc::Yss.load_elements(
        location: %w(Tokyo Kyoto),
        facility: %w(Library School)
      )
      expect(elements).to eq({
        location: %w(Tokyo Kyoto),
        facility: %w(Library School)
      })
    end

    it 'calls .load_element when args includes Hash' do
      hash = {location: {csv: 'locations.csv'}}
      expect(Ferenc::Yss).to receive(:load_element).with(:location, {csv: 'locations.csv'})
      Ferenc::Yss.load_elements hash
    end
  end

  describe '.load_element' do
    before do
      @args = {
        csv: 'spec/fixtures/locations.csv',
        attributes: %w(to_s name population abbr),
      }
    end

    after do
      Ferenc::Element.constants.each do |const|
        Ferenc::Element.send :remove_const, const
      end
    end

    it 'loads from csv' do
      locations = Ferenc::Yss.load_element(:location, @args)
      expect(locations.length).to eq 2
      expect(locations[0].to_h).to eq({
        to_s: 'Tokyo', name: 'tokyo', population: '1340', abbr: 'Tky'
      })
      expect(locations[1].to_h).to eq({
        to_s: 'Kyoto', name: 'kyoto', population: '147', abbr: 'Kyt'
      })
    end

    it 'defines class' do
      Ferenc::Yss.load_element(:location, @args)
      expect(Ferenc::Element::Location).to be_a(Class)
    end

    it 'defines .all' do
      locations = Ferenc::Yss.load_element(:location, @args)
      expect(Ferenc::Element::Location.all).to eq locations
    end

    it 'defines #vocabularies when arg keys includes vocabularies' do
      @args[:vocabularies] = %w(to_s abbr)
      locations = Ferenc::Yss.load_element(:location, @args)
      expect(locations[0].vocabularies).to eq %w(Tokyo Tky)
      expect(locations[1].vocabularies).to eq %w(Kyoto Kyt)
    end
  end


  describe '#campaigns' do
    before do
      @yss = subject
    end

    it 'creates campaigns' do
      @yss.config = {
        campaigns: [
          {name: 'Campaign1', budget: 1234},
          {name: 'Campaign2', budget: 2345}
        ],
        elements: {location: %w(Tokyo)},
      }

      campaigns = @yss.campaigns
      expect(campaigns.length).to eq 2
      expect(campaigns[0].name).to eq 'Campaign1'
      expect(campaigns[0].budget).to eq 1234
      expect(campaigns[1].name).to eq 'Campaign2'
      expect(campaigns[1].budget).to eq 2345
    end

    it 'creates ads' do
      @yss.config = {
        campaigns: [
          { name: 'Campaign1', budget: 1234,
            ad_group: {
              ads: [
                { title: '<<location>>',
                  desc1: '<<location>> is good.',
                  desc2: '<<location>> is nice.',
                },
              ]
            }
          },
        ],
        elements: {location: %w(Tokyo Kyoto)},
      }
      ads = @yss.campaigns.first.ads
      expect(ads.length).to eq 2
      expect(ads[0].title).to eq 'Tokyo'
      expect(ads[0].desc1).to eq 'Tokyo is good.'
      expect(ads[0].desc2).to eq 'Tokyo is nice.'
      expect(ads[1].title).to eq 'Kyoto'
      expect(ads[1].desc1).to eq 'Kyoto is good.'
      expect(ads[1].desc2).to eq 'Kyoto is nice.'
    end

    it 'mixes elements' do
      @yss.config = {
        campaigns: [{
          name: 'Campaign1', budget: 1234,
          ad_group: {
            ads: [{title: '<<location>> <<faculty>>'}]
          },
          elements: [:location, :faculty]
        }],
        elements: {
          location: %w(Tokyo Kyoto),
          faculty: %w(Library School)
        },
      }
      ads = @yss.campaigns.first.ads
      expect(ads.map(&:title)).to eq(
        ['Tokyo Library', 'Tokyo School', 'Kyoto Library', 'Kyoto School']
      )
    end

    it 'follows elements order' do
      @yss.config = {
        campaigns: [{
          name: 'Campaign1', budget: 1234,
          ad_group: {
            ads: [{title: '<<location>> <<faculty>>'}]
          },
          elements: [:faculty, :location]
        }],
        elements: {
          location: %w(Tokyo Kyoto),
          faculty: %w(Library School)
        },
      }
      ads = @yss.campaigns.first.ads
      expect(ads.map(&:title)).to eq(
        ['Tokyo Library', 'Kyoto Library', 'Tokyo School', 'Kyoto School']
      )
      expect(ads.map(&:keyword)).to eq(
        ['Library Tokyo', 'Library Kyoto', 'School Tokyo', 'School Kyoto']
      )
    end

    it 'focuses elements' do
      @yss.config = {
        campaigns: [{
          name: 'Campaign1', budget: 1234,
          ad_group: {
            ads: [{title: '<<location>> <<faculty>>'}]
          },
          elements: [:location, :faculty],
          focused_elements: [:faculty]
        }],
        elements: {
          location: %w(Tokyo Kyoto),
          faculty: %w(Library School)
        },
      }
      ads = @yss.campaigns.first.ads
      expect(ads.map(&:keyword)).to eq(
        ['Tokyo +Library', 'Tokyo +School', 'Kyoto +Library', 'Kyoto +School']
      )
    end

    it 'sets link_url' do
      @yss.config = {
        campaigns: [{
          name: 'Campaign1', budget: 1234,
          domain: 'campaign.com',
          ad_group: {
            ads: [{}]
          }
        }]
      }
      allow(@yss).to receive(:elements) {
        {
          location: [double(to_param: 'tokyo'), double(to_param: 'kyoto')],
          faculty: [double(to_param: 'library')],
        }
      }
      ad_groups = @yss.campaigns.first.ad_groups
      expect(ad_groups.map(&:link_url)).to eq(
        ['http://campaign.com/tokyo_library.html', 'http://campaign.com/kyoto_library.html']
      )
    end

    it 'applies path to link_url' do
      @yss.config = {
        campaigns: [{
          name: 'Campaign1', budget: 1234,
          domain: 'campaign.com',
          ad_group: {
            path: '<<location>>/<<faculty>>/',
            ads: [{}]
          },
        }]
      }
      allow(@yss).to receive(:elements) {
        {
          location: [double(to_param: 'tokyo'), double(to_param: 'kyoto')],
          faculty: [double(to_param: 'library')],
        }
      }
      ad_groups = @yss.campaigns.first.ad_groups
      expect(ad_groups.map(&:link_url)).to eq(
        ['http://campaign.com/tokyo/library/', 'http://campaign.com/kyoto/library/']
      )
    end
  end
end
