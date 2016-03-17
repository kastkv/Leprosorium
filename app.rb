#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' # чтобы не перезапускать sinatra каждый раз

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

# get '/New' do   #добавляем обработчик
#  erb "Hello World" # чтобы выводился с нашим шаблоном пишем erb
# end

get '/New' do   
 erb :new
end