# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'pg'

class Memo
  CONNECTION = PG.connect(dbname: 'memos', user: 'postgres', password: 'password')
  CONNECTION.freeze

  def self.create_table
    CONNECTION.exec("CREATE TABLE IF NOT EXISTS memo_table ( memoid TEXT PRIMARY KEY, title TEXT, content TEXT );")
  end

  def self.read_memos
    CONNECTION.exec("SELECT memoid, title FROM memo_table;")
  end

  def self.select_memo(id)
    CONNECTION.exec("SELECT * FROM memo_table WHERE memoid = $1;", [id])
  end

  def self.write_memo(id, title, content)
    CONNECTION.exec("INSERT INTO memo_table ( memoid, title, content ) VALUES ( '#{id}', '#{title}', '#{content}' );")
  end

  def self.edit_memo(id, title, content)
    CONNECTION.exec("UPDATE memo_table SET ( title, content ) = ( $1, $2 ) WHERE memoid = $3;", [title, content, id])
  end

  def self.delete_memo(id)
    CONNECTION.exec("DELETE FROM memo_table WHERE memoid = $1;", [id])
  end
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/memos' do
  Memo.create_table
  @memos = Memo.read_memos
  erb :top_memo
end

get '/memos/new' do
  erb :new_memo
end

post '/memos' do
  memo_id = SecureRandom.hex(10)
  Memo.write_memo(memo_id, params[:title], params[:content])
  @memos = Memo.read_memos
  redirect '/memos'
end

get '/memos/:memo_id' do
  @memo = Memo.select_memo(params[:memo_id])[0]
  erb :show_memo
end

get '/memos/:memo_id/edit' do
  @memo = Memo.select_memo(params[:memo_id])[0]
  erb :edit_memo
end

patch '/memos/:memo_id' do
  Memo.edit_memo(params[:memo_id], params[:title], params[:content])
  @memo = Memo.select_memo(params[:memo_id])[0]
  erb :show_memo
end

delete '/memos' do
  Memo.delete_memo(params[:memo_id])
  @memos = Memo.read_memos
  erb :top_memo
end
