require './lib/atnd.rb'
require './lib/twitter.rb'
require 'pp'

def get_token(source)
  consumer_credential(source)
end

def consumer_credential(source)
  auth = []
  open(source) do |f|
    while (line = f.gets) do
      auth << line.chomp 
    end
  end
  pp auth
  auth
end

consumer_key, consumer_secret, access_token, access_token_secret = get_token("auth.txt")
members = ATND.event_members("61150")
app = ATND_LISTING.app(consumer_key, consumer_secret, access_token, access_token_secret )
list = app.create_list("test",:description=>"テストやで。",:mode=>"private")
app.add_list_members(list, members)

