# Reads the settings from the yaml file
class Settings
  def self.all
    @settings ||= begin
      if ENV['ENV'] == 'test'
        YAML.load_file(File.join('.', 'spec/config.test.yml'))
      else
        YAML.load_file(File.join('.', 'config.yml'))
      end
    end
  end
end
