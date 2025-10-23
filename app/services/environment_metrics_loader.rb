# frozen_string_literal: true

require "csv"
require "pathname"

class EnvironmentMetricsLoader
  DEFAULT_DIRECTORY = Rails.root.join("storage", "external_metrics").freeze
  FILE_GLOB = "*.csv"

  Result = Struct.new(:samples, :chart_data, :source_file, :error, keyword_init: true)

  def initialize(directory: DEFAULT_DIRECTORY)
    @directory = Pathname(directory)
  end

  def call
    return empty_result unless @directory.directory?

    latest_file_path = latest_csv_file
    return empty_result unless latest_file_path

    samples = parse_csv(latest_file_path)
    chart_data = build_chart_data(samples)

    Result.new(
      samples: samples,
      chart_data: chart_data,
      source_file: Pathname(latest_file_path)
    )
  rescue StandardError => e
    Rails.logger.error("[EnvironmentMetricsLoader] Failed to load metrics: #{e.class}: #{e.message}")
    empty_result(error: e.message)
  end

  private

  def latest_csv_file
    Dir.glob(@directory.join(FILE_GLOB).to_s).max_by { |path| File.mtime(path) }
  end

  def parse_csv(file_path)
    csv = CSV.read(file_path, headers: true)
    csv.each_with_object([]) do |row, collection|
      timestamp = parse_timestamp(row["datetime"] || row["Datetime"])
      next unless timestamp

      collection << {
        timestamp: timestamp,
        temperature: parse_numeric(row["Temperature"]),
        humidity: parse_numeric(row["Humidity"]),
        co2: parse_numeric(row["CO2"])
      }
    end.sort_by { |entry| entry[:timestamp] }
  end

  def parse_timestamp(value)
    return if value.blank?

    Time.zone.parse(value.to_s)
  rescue ArgumentError
    nil
  end

  def parse_numeric(value)
    return if value.blank?

    Float(value)
  rescue ArgumentError, TypeError
    nil
  end

  def build_chart_data(samples)
    return if samples.blank?

    {
      columns: [
        { type: "string", label: "時刻" },
        { type: "number", label: "温度 (°C)" },
        { type: "number", label: "湿度 (%)" },
        { type: "number", label: "CO2 (ppm)" }
      ],
      rows: samples.map do |sample|
        [
          sample[:timestamp].in_time_zone.strftime("%H:%M"),
          sample[:temperature],
          sample[:humidity],
          sample[:co2]
        ]
      end
    }
  end

  def empty_result(error: nil)
    Result.new(samples: [], chart_data: nil, source_file: nil, error: error)
  end
end
