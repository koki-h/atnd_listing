require './lib/atnd.rb'
require './lib/twitter.rb'
consumer_key, consumer_secret, access_token, access_token_secret = ATND_LISTING.get_token("auth.txt")
members = ATND.event_members("61150")
app = ATND_LISTING.app(consumer_key, consumer_secret, access_token, access_token_secret )


list = app.create_list("test",:description=>"テストやで。",:mode=>"private")
app.add_list_members(list, members)
