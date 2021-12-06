# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def read_memos
  File.open('memos.json') { |f| JSON.load(f) }
end

def write_memo(memos)
  File.open('memos.json', 'w') { |f| JSON.dump(memos, f) }
end

def select_memo
  @id = params[:memo_id]
  @memos = read_memos
  @memo = @memos[@id]
end

get '/memos' do
  @memos = read_memos
  erb :top_memo
end

get '/memos/new' do
  erb :new_memo
end

post '/memos' do
  memo_id = SecureRandom.hex(10)
  @memos = read_memos
  @memos[memo_id] = { 'title' => params[:title], 'content' => params[:content] }
  write_memo(@memos)
  redirect '/memos'
end

get '/memos/:memo_id' do
  select_memo
  erb :show_memo
end

get '/memos/:memo_id/edit' do
  select_memo
  erb :edit_memo
end

patch '/memos/:memo_id' do
  select_memo
  @memo['title'] = params[:title]
  @memo['content'] = params[:content]
  write_memo(@memos)
  erb :show_memo
end

delete '/memos' do
  @memos = read_memos
  @memos.delete(params[:memo_id])
  write_memo(@memos)
  erb :top_memo
end
