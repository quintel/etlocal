module Versions
  CONFIG = YAML.load_file(Rails.root.join('config/versions.yml')).freeze

  def self.versions
    @versions ||= CONFIG['versions']
  end

  def self.find_by_name(name)
    versions.find { |v| v['name'] == name }
  end

  def self.find_by_freeze_date(date)
    versions.find { |v| v['freeze_date'] == date }
  end

  def self.default_version
    versions.find { |v| v['freeze_date'].nil? } || versions.first
  end
end
