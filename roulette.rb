require 'sinatra'
require 'chatbot'

post '/' do
  ChatBot.processMessage(request.body.read)
end

Chatbot.command '!roulette' do |message|
end

Chatbot.command '!pull' do |message|
end
