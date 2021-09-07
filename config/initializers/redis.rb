if Rails.env == 'staging'
	uri = ENV["REDISTOGO_URL"] || "redis://redistogo:b5a9631594ff480d9747f9d6929f7f23@crestfish.redistogo.com:9219/"
	REDIS = Redis.new(:url => uri)
else Rails.env == 'development'
	uri = ENV["REDISTOGO_URL"] || "redis://localhost:6379"
	REDIS = Redis.new(:url => uri)
end