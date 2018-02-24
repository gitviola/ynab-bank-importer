class Settings
  def self.all
    if ENV['ENV'] == 'test'
      YAML.load_file(File.join('.', 'spec/config.test.yml'))
    else
      YAML.load_file(File.join('.', 'config.yml'))
    end
  end
end
