class YmlReadOnlyRecord
  def initialize(attr_hash)
    attr_hash.symbolize_keys!
    attr_hash.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.all
    self.load_collective_file || self.load_directory
  end

  def self.yml_store
    self.name.underscore.pluralize
  end

  def self.find(key)
    return nil unless key

    key = key.to_sym
    all.find { |p| p.key == key }
  end

  def self.constraint
    Regexp.new(all.map(&:key).join("|"))
  end

  private

  def self.load_collective_file
    file = "#{Rails.root}/config/#{yml_store}.yml"
    return false unless File.exist? file
    YAML.load_file(file).map {|i| self.new i }
  end

  def self.load_directory
    items = []
    Dir.glob("#{Rails.root}/config/#{yml_store}/**/*.yml") do |yml_file|
      begin
        items << self.new( YAML.load_file yml_file )
      rescue StandardError => e
        puts "Error reading #{yml_file}"
        raise e
      end
    end
    items
  end
end
