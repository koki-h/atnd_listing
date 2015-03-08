require 'sinatra'
require 'sinatra/reloader' if development?
require 'omniauth-twitter'
require './lib/atnd.rb'
require './lib/twitter.rb'
require "pp"
# 以下はomniauth-twitterで予約されたパス
#
# /auth/twitter           Twitterの認証ページヘリダイレクトさせるためのパス（作成の必要なし）
# /auth/twitter/callback  Twitterでの認証後にコールバックされるパス（アクセストークンの取得等を行う）
# /auth/failure           Twitterでの認証が失敗した場合にリダイレクトされるパス（失敗した旨をユーザへ伝えるメッセージ表示とか）

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
  def current_user
    !session[:uid].nil?
  end
end

before do
  pass if request.path_info =~ /^\/auth\//
  redirect to('/auth/twitter') unless current_user
end

get '/auth/twitter/callback' do
  session[:access_token] = env['omniauth.auth']['extra']['access_token']
  session[:uid] = env['omniauth.auth']['uid']
  redirect to('/')
end

get '/auth/failure' do
  '理由はわかりませんが認証できませんでした。ごめんね。'
end

get '/' do
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
