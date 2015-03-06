require 'twitter'
require 'pp'

module ATND_LISTING
  def self.get_token(source)
    auth = []
    open(source) do |f|
      while (line = f.gets) do
        auth << line.chomp 
      end
    end
    auth
  end

  def self.app(consumer_key, consumer_secret, access_token, access_token_secret)
    tw = Twitter::REST::Client.new do |config|
      config.consumer_key        = consumer_key
      config.consumer_secret     = consumer_secret
      config.access_token        = access_token
      config.access_token_secret = access_token_secret
    end
  end
end

