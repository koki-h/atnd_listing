require 'sinatra'
require 'sinatra/reloader' if development?
require 'omniauth-twitter'
require './lib/atnd.rb'
require './lib/twitter.rb'
require "pp"

def consumer_credential(source)
  auth = []
  open(source) do |f|
    while (line = f.gets) do
      auth << line.chomp 
    end
  end
  auth
end

configure do
  enable :sessions

  consumer_key,consumer_secret = consumer_credential("auth.txt")
  use OmniAuth::Builder do
    provider :twitter, consumer_key, consumer_secret
  end
end

helpers do
  # current_userは認証されたユーザーのことです
  def current_user
    !session[:uid].nil?
  end
end

before do
  # /auth/からパスが始まる時はTwitterへリダイレクトしたいわけではないので
  pass if request.path_info =~ /^\/auth\//

  # /auth/twitterはOmniAuthが使います
  # /auth/twitterに当てはまる場合、Twitterへリダイレクトします。
  redirect to('/auth/twitter') unless current_user
end
get '/auth/twitter/callback' do
  # ひょっとするとデータベースにも登録したくなるかもしれません。
  pp env['omniauth.auth']['access_token']
  session[:access_token] = env['omniauth.auth']['extra']['access_token']
  session[:uid] = env['omniauth.auth']['uid']
  # これはあなたのアプリケーションへユーザーを戻すメソッドです
  redirect to('/')
end

get '/auth/failure' do
  # OmniAuthはなにか問題が起こると/auth/failureへリダイレクトします。
  # ここにあなたは何らかの処理を書くべきでしょう
end

get '/' do
  pp session[:access_token]
  'Hello omniauth-twitter!'
end

get '/exec' do
  consumer_key,consumer_secret = consumer_credential("auth.txt")
  access_token = session[:access_token].token
  access_token_secret = session[:access_token].secret
  members = ATND.event_members("61150")
  app = ATND_LISTING.app(consumer_key, consumer_secret, access_token, access_token_secret )
  list = app.create_list("test",:description=>"テストやで。",:mode=>"private")
  app.add_list_members(list, members)
  "リストを作成しました。"
end
