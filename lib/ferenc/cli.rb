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
    method_option :yss, type: :string, aliases: '-y', desc: 'Use yss settings file'
    def generate element, *attrs
      attrs = %w(to_param to_s) + attrs
      @element = element.singularize
      @elements = element.pluralize
      @attributes = attrs
      template = options[:template] || 'default'
      @yss_file = options[:yss] || 'yss.yml'
      source_paths << File.expand_path("../../../templates/generate/#{template}", __FILE__)

      directory 'data'
      directory 'source'
      append_to_file 'config.rb', <<EOS
Ferenc::Element::#{@element.capitalize}.all.each do |#{@element}|
  proxy "\#{#{@element}.#{attrs.first}}.html", '#{@elements}.html', locals: {#{@element}: #{@element}}, ignore: true
end
EOS
      append_to_file "data/#{@yss_file}", <<EOS
  #{@element}:
    csv: 'data/#{@elements}.csv'
    attributes: [#{attrs.join ', '}]
    vocabularies: [#{attrs.join ', '}]
EOS
      append_to_file 'source/layouts/layout.slim', <<EOS
        - sitemap.resources.select{|res| res.metadata[:locals][:#{@element}]}.each do |res|
          = link_to res.metadata[:locals][:#{@element}].to_s, res.path
EOS
    end
  end
end
