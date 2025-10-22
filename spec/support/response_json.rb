module ResponseJson
  def response_json
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include ResponseJson, type: :request
end
