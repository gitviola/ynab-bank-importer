class Settings
  def self.all
    YAML.load_file(File.join('.', 'config.yml'))
  end
end
