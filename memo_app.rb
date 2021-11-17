# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
File.open('memos.json', 'w') do |f|
  hash = {}
  JSON.dump(hash, f)
end
memo_id = 0

get '/memos' do
  @memos = File.open('memos.json') { |f| JSON.load(f) }
  erb :top_memo
end

get '/memos/new' do
  erb :new_memo
end

post '/memos' do
  File.open('memos.json') { |f| JSON.load(f) }
  hash[memo_id] = { 'title' => h(params[:title]), 'content' => h(params[:content]) }
  File.open('memos.json', 'w') { |f| JSON.dump(hash, f) }
  @memos = hash
  memo_id += 1
  redirect '/memos'
end

get '/memos/:memo_id' do
  hash = File.open('memos.json') { |f| JSON.load(f) }
  @id = params[:memo_id]
  @memo = hash[@id]
  erb :show_memo
end

get '/memos/:memo_id/edit' do
  hash = File.open('memos.json') { |f| JSON.load(f) }
  @id = params[:memo_id]
  @memo = hash[@id]
  erb :edit_memo
end

patch '/memos/:memo_id' do
  hash = File.open('memos.json') { |f| JSON.load(f) }
  @id = params[:memo_id]
  hash[@id]['title'] = h(params[:title])
  hash[@id]['content'] = h(params[:content])
  File.open('memos.json', 'w') { |f| JSON.dump(hash, f) }
  @memo = hash[@id]
  erb :show_memo
end

delete '/memos' do
  hash = File.open('memos.json') { |f| JSON.load(f) }
  hash.delete(params[:memo_id])
  File.open('memos.json', 'w') { |f| JSON.dump(hash, f) }
  @memos = hash
  erb :top_memo
end
