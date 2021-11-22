# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def read_memo
  File.open('memos.json') { |f| JSON.load(f) }
end

def write_memo(hash)
  File.open('memos.json', 'w') { |f| JSON.dump(hash, f) }
end

get '/memos' do
  @memos = read_memo
  erb :top_memo
end

get '/memos/new' do
  erb :new_memo
end

post '/memos' do
  hash = read_memo
  memo_id = Time.now.strftime("%Y%m%d%H%M%S")
  hash[memo_id] = { 'title' => params[:title], 'content' => params[:content] }
  write_memo(hash)
  @memos = hash
  redirect '/memos'
end

get '/memos/:memo_id' do
  hash = read_memo
  @id = params[:memo_id]
  @memo = hash[@id]
  erb :show_memo
end

get '/memos/:memo_id/edit' do
  hash = read_memo
  @id = params[:memo_id]
  @memo = hash[@id]
  erb :edit_memo
end

patch '/memos/:memo_id' do
  hash = read_memo
  @id = params[:memo_id]
  hash[@id]['title'] = params[:title]
  hash[@id]['content'] = params[:content]
  write_memo(hash)
  @memo = hash[@id]
  erb :show_memo
end

delete '/memos' do
  hash = read_memo
  hash.delete(params[:memo_id])
  write_memo(hash)
  @memos = hash
  erb :top_memo
end
