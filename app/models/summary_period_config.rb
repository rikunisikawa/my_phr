# frozen_string_literal: true

module SummaryPeriodConfig
  SHORT_TERM_TIMEFRAME_HOURS = [3, 6, 12, 24, 72].freeze

  module_function

  def short_term_timeframe_options
    [
      ["直近3時間", 3],
      ["直近6時間", 6],
      ["直近12時間", 12],
      ["直近24時間", 24],
      ["直近3日間", 72]
    ]
  end
end
