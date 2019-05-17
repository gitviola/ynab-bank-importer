# Reads the settings from the yaml file
class Settings
  def self.all
    @settings ||= begin
      if ENV['ENV'] == 'test'
        YAML.load_file(File.join('.', 'spec/config.test.yml'))
      else
        # check if the first command line parameter contains a value and use that for the config file
        first_arg, *the_rest = ARGV
        if !first_arg.to_s.strip.empty?
          YAML.load_file(File.join('.', first_arg.to_s.strip))
        else
          YAML.load_file(File.join('.', 'config.yml'))
        end
      end
    end
  end
end
