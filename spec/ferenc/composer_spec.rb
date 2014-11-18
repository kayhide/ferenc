require 'spec_helper'

describe Ferenc::Composer do
  before do
    @composer = subject
    @composer.vocabularies ={
      'size' => %w(small big),
      'food' => %w(apple banana),
      'empty' => [],
    }
  end

  describe '#fit' do
    it 'returns first candidate' do
      text = '<<size>> <<food>>'
      expect(@composer.fit text, 100).to eq 'small apple'
    end

    it 'rejects too long candidates ' do
      text = '<<size>> <<food>>'
      expect(@composer.fit text, 10).to eq 'big apple'
    end
  end

  describe '#expand' do
    it 'returns candidates' do
      text = 'my <<food>> is good.'
      expect(@composer.expand text).to eq(
        ['my apple is good.', 'my banana is good.']
      )
    end

    it 'creates products' do
      text = '<<size>> <<food>>'
      expect(@composer.expand text).to eq(
        ['small apple', 'small banana', 'big apple', 'big banana']
      )
    end

    it 'weighs elements' do
      text = '<<size>> <<<food>>>'
      expect(@composer.expand text).to eq(
        ['small apple', 'big apple', 'small banana', 'big banana']
      )
    end

    it 'accepts empty vocabularies' do
      text = '<<empty>><<food>>'
      expect(@composer.expand text).to eq(
        ['apple', 'banana']
      )
    end
  end
end
