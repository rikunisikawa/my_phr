# frozen_string_literal: true

require "rails_helper"
require "tmpdir"

RSpec.describe EnvironmentMetricsLoader do
  describe "#call" do
    it "returns parsed samples and chart data from the newest CSV" do
      Dir.mktmpdir do |dir|
        csv_path = File.join(dir, "environment.csv")
        File.write(csv_path, <<~CSV)
          datetime,Temperature,Humidity,CO2
          2025-10-22T11:33:33+09:00,23.4,60.1,3360
          2025-10-22T11:34:33+09:00,23.6,57.7,3617
          2025-10-22T11:35:33+09:00,23.7,57.8,3782
        CSV

        result = described_class.new(directory: dir).call

        expect(result.samples.length).to eq(3)
        expect(result.samples.first[:temperature]).to eq(23.4)
        expect(result.samples.last[:co2]).to eq(3782.0)
        expect(result.source_file.basename.to_s).to eq("environment.csv")

        expect(result.chart_data[:columns].map { |column| column[:label] }).to eq([
          "時刻", "温度 (°C)", "湿度 (%)", "CO2 (ppm)"
        ])
        expect(result.chart_data[:rows].first.first).to eq("11:33")
      end
    end

    it "returns an empty result when directory is missing" do
      result = described_class.new(directory: "non-existent").call

      expect(result.samples).to be_empty
      expect(result.chart_data).to be_nil
      expect(result.source_file).to be_nil
    end
  end
end
