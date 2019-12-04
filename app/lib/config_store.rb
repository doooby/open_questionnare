class ConfigStore

  def self.loaded_configs
    @loaded_configs = {}
  end

  def self.from file
    @loaded_configs[file] ||= begin
      config = new file, load_data!(file)
      @loaded_configs[file] = config
    end
  end

  def self.load_data! file
    path = Rails.root.join('config', "#{file}.yml")
    data = YAML.load_file path rescue nil
    raise "invalid or missing config #{file}" unless data
    data
  end

  def initialize file, data
    env = Rails.env
    raise "config #{file} is missing #{env} env" unless data.key? env
    @file = file
    @data = data[env]
  end

  def fetch *args, &block
    @data.dig(*args) || block&.call || begin
      raise "config #{file} doesn't contain value #{args.join '.'}"
    end
  end

end
