require 'spec_helper'

describe Ferenc::Mixer do
  before do
    @mixer = subject
  end

  describe '#mix' do
    describe 'with only strings' do
      it 'yields with words and elements' do
        @mixer.elements = {
          'location' => %w(Tokyo),
          'facility' => %w(Library),
        }
        @mixer.mix do |words, location, facility|
          expect(words).to eq %w(Tokyo Library)
          expect(location).to eq 'Tokyo'
          expect(facility).to eq 'Library'
        end
      end

      it 'creates products' do
        @mixer.elements = {
          'location' => %w(Tokyo Kyoto),
          'facility' => %w(Library School),
        }
        @mixer.mix do |words, location, facility|
          [location, facility]
        end

        expect(@mixer.products).to eq [
          %w(Tokyo Library), %w(Tokyo School),
          %w(Kyoto Library), %w(Kyoto School)
        ]
      end
    end

    describe 'with object' do
      it 'digs vocabularies' do
        @mixer.elements = {
          'location' => [
            double(vocabularies: %w(Tokyo Tky)),
            double(vocabularies: %w(Kyoto Kyt)),
          ],
          'facility' => %w(Library),
        }
        @mixer.mix do |words, location, facility|
          words
        end

        expect(@mixer.products).to eq [
          %w(Tokyo Library), %w(Tky Library),
          %w(Kyoto Library), %w(Kyt Library)
        ]
      end
    end
  end

  describe '#compose' do
    it 'calls Composer#fit' do
      @mixer.templates['text'] = 'template text'
      expect(@mixer.composer).to receive(:fit).with('template text', 10)
      @mixer.compose('text', 10)
    end

    it 'accepts Symbol for template key' do
      @mixer.templates['text'] = 'template text'
      expect(@mixer.composer).to receive(:fit).with('template text', 10)
      @mixer.compose(:text, 10)
    end
  end

  describe 'when products are all valid' do
    before do
      @mixer.elements = {'location' => %w(Tokyo Kyoto)}
      @mixer.mix do |words, location|
        double(valid?: true)
      end
    end

    describe '#valid?' do
      it 'returns true' do
        expect(@mixer.valid?).to eq true
      end
    end

    describe '#errors' do
      it 'returns empty' do
        expect(@mixer.errors).to eq []
      end
    end
  end

  describe 'when products are some invalid' do
    before do
      @mixer.elements = {'location' => %w(Tokyo Kyoto)}
      @mixer.mix do |words, location|
        double(
          location: location,
          valid?: location == 'Tokyo'
        )
      end
    end

    describe '#valid?' do
      it 'returns false' do
        expect(@mixer.valid?).to eq false
      end
    end

    describe '#errors' do
      it 'returns invalid product' do
        expect(@mixer.errors.map(&:valid?)).to eq [false]
        expect(@mixer.errors.map(&:location)).to eq %w(Kyoto)
      end
    end
  end
end
