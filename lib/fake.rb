# Helper module to tuck away some ugly file operations
module Fake
  Fake::REQUEST = 0
  Fake::RESPONSE = 1
  
  def self.to_array(cache_file)
    if File.exist?(cache_file)
      File.open(cache_file, "r") do |f|
        YAML.load(f.read)
      end
    end || []
  end
end