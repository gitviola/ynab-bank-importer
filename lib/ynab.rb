class YNAB
  require 'fileutils'

  EXPORT_DIR = (File.expand_path('..', File.dirname(__FILE__)) + '/export').freeze
  CACHE_DIR  = (File.expand_path('..', File.dirname(__FILE__)) + '/.cache').freeze

  def self.cleanup
    FileUtils.rm_rf(EXPORT_DIR)
    FileUtils.rm_rf(CACHE_DIR)
  end
end
