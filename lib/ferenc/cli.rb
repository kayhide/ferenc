require 'bundler'
require 'thor'
require 'active_support/inflector'

module Ferenc
  class Cli < Thor
    include Thor::Actions

    attr_reader :element, :elements

    desc 'init SITENAME', 'Initialize for ferenc'
    method_option :template, type: :string, aliases: '-t', desc: 'Use specific template'
    def init site_name
      template = options[:template] || 'default'
      source_paths << File.expand_path('../../../templates/init', __FILE__)

      directory template, site_name
    end

    desc 'generate ELEMENTS [attrs]', 'Generate elements'
    def generate element, *attrs
      attrs = %w(to_param to_s) + attrs
      @element = element.singularize
      @elements = element.pluralize
      @attributes = attrs
      template = options[:template] || 'default'
      @yss_file = 'data/yss.yml'
      source_paths << File.expand_path("../../../templates/generate/#{template}", __FILE__)

      directory 'data'
      directory 'source'
      append_to_file 'config.rb', <<EOS
Ferenc::Element::#{@element.capitalize}.all.each do |#{@element}|
  proxy "\#{#{@element}.#{attrs.first}}.html", '#{@elements}.html', locals: {#{@element}: #{@element}}, ignore: true
end
EOS
      append_to_file @yss_file, <<EOS
  #{@element}:
    csv: 'data/#{@elements}.csv'
    attributes: [#{attrs.join ', '}]
    vocabularies: [#{attrs.join ', '}]
EOS
      if File.exist? 'source/layouts/layout.slim'
        append_to_file 'source/layouts/layout.slim', <<EOS
        - sitemap.resources.select{|res| res.metadata[:locals][:#{@element}]}.each do |res|
          = link_to res.metadata[:locals][:#{@element}].to_s, res.path
EOS
      end
    end

    desc 'export', 'Export csv for yss'
    def export
      Bundler.require
      @yss_file = 'data/yss.yml'
      @yss = Ferenc::Yss.load(@yss_file)
      campaigns = @yss.campaigns
      campaigns.each do |campaign|
        if campaign.valid?
          campaign.display STDOUT
          FileUtils.mkdir_p 'exports'
          FileUtils.chdir 'exports' do
            open("#{campaign.name}_#{campaign.starts_on.strftime '%Y%m%d'}.csv", 'w') << campaign.to_csv
          end
        else
          campaign.errors.each do |ad|
            puts ad.keyword.red.bold
          end
        end
      end
    end
  end
end
