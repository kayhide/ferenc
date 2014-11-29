require 'spec_helper'
require 'fileutils'
require File.expand_path('../../../lib/ferenc/cli', __FILE__)

describe Ferenc::Cli do
  before do
    @original_dir = Dir.pwd
    @cli_dir = File.expand_path('../../../tmp/cli', __FILE__)
    FileUtils.rm_rf @cli_dir
    FileUtils.mkdir_p @cli_dir
  end

  after do
    Dir.chdir @original_dir
  end

  describe '#init' do
    before do
      Dir.chdir @cli_dir
    end

    it 'creates files and dirs' do
      quietly do
        subject.invoke :init, ['site-1']
      end

      expect(File.exists? 'site-1/.gitignore').to eq true
      expect(File.exists? 'site-1/Gemfile').to eq true
      expect(Dir.exists? 'site-1/data').to eq true
      expect(Dir.exists? 'site-1/source').to eq true
    end
  end

  describe '#generate' do
    before do
      @dir = File.join(@cli_dir, 'site-1')
      FileUtils.cp_r File.expand_path('../../fixtures/cli/site-1', __FILE__), @dir
      Dir.chdir @dir
    end

    it 'creates files' do
      quietly do
        subject.invoke :generate, ['location', 'name', 'to_s']
      end

      expect(File.exists? 'data/locations.csv').to eq true
    end
  end

  describe '#export' do
    before do
      @dir = File.join(@cli_dir, 'site-1')
      FileUtils.cp_r File.expand_path('../../fixtures/cli/site-1', __FILE__), @dir
      Dir.chdir @dir
    end

    it 'creates files' do
      quietly do
        subject.invoke :export
      end

      expect(File.exists? 'exports/campaign-1.csv').to eq true
    end
  end
end

