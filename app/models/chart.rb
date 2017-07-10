class Chart
  attr_reader :key, :options

  def initialize(key, options)
    @key     = key
    @options = options || {}
  end

  def scale
    @options['scale']
  end

  def color_stops
    @options['color_stops']
  end

  def layers
    @options['layers']
  end

  def legend_type
    @options['legend_type']
  end

  def self.all
    records
  end

  def self.find(key)
    records.detect do |record|
      record.key == key
    end
  end

  private

  def self.records
    @records ||=
      YAML.load_file(Rails.root.join("config", "charts.yml"))
          .map { |key, opts| new(key, opts) }
  end
end
