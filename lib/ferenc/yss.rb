require 'ferenc/yss/campaign'
require 'ferenc/yss/ad'

module Ferenc
  class Yss
    class << self
      def load file
        yss = Yss.new
        yss.config = config = YAML.load_file(file)

        yss.mixer = Mixer.new
        yss.mixer.elements = config['elements']
        yss.mixer.vocabularies = config['vocabularies']
        yss.mixer.templates = config['templates']

        yss
      end
    end
  end
end
