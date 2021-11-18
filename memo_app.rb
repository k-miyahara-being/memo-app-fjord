# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

class Memo
  def self.read
    File.open('memos.json') { |f| JSON.load(f) }
  end

  def self.write(hash)
    File.open('memos.json', 'w') { |f| JSON.dump(hash, f) }
  end
end

Memo.write({})
memo_id = 0

get '/memos' do
  @memos = Memo.read
  erb :top_memo
end

get '/memos/new' do
  erb :new_memo
end

post '/memos' do
  hash = Memo.read
  hash[memo_id] = { 'title' => h(params[:title]), 'content' => h(params[:content]) }
  Memo.write(hash)
  @memos = hash
  memo_id += 1
  redirect '/memos'
end

get '/memos/:memo_id' do
  hash = Memo.read
  @id = params[:memo_id]
  @memo = hash[@id]
  erb :show_memo
end

get '/memos/:memo_id/edit' do
  hash = Memo.read
  @id = params[:memo_id]
  @memo = hash[@id]
  erb :edit_memo
end

patch '/memos/:memo_id' do
  hash = Memo.read
  @id = params[:memo_id]
  hash[@id]['title'] = h(params[:title])
  hash[@id]['content'] = h(params[:content])
  Memo.write(hash)
  @memo = hash[@id]
  erb :show_memo
end

delete '/memos' do
  hash = Memo.read
  hash.delete(params[:memo_id])
  Memo.write(hash)
  @memos = hash
  erb :top_memo
end
