require 'sinatra'
require 'chatbot'
require 'data_mapper'
require './models/user'
require './models/game'
require './models/player_order'
require './models/bet'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://rohit:lol123@localhost/roulette')
DataMapper.finalize
DataMapper.auto_migrate!

post '/' do
  ChatBot.processMessage(request.body.read)
end

Chatbot.command '!roulette' do |message|
  if game_in_progress?
    return "A game is already in progress"
  else
    initial_bet = message.message.split(" ").drop(1).join(" ").to_i
    if initial_bet > 0
      start_new_game(message.sender_id, initial_bet)
    else
      return "Invalid initial bet"
    end
  end
end

Chatbot.command '!bet' do |message|
  unless game_in_pregame?
    return "No game in progresS"
  end
    bet = message.message.split(" ").drop(1).join(" ").to_i
    if bet > 0
      return add_user_to_game(message.sender_id, bet)
    else
      return "Invalid initial bet"
    end
end

Chatbot.command '!pull' do |message|
end

def game_in_progress?
  return Game.first(:status.not => "in_progress").nil?
end

def game_in_pregame?
  return Game.first(:status.not => "pregame").nil?
end

def start_new_game(user_id, initial_bet)
  user = User.first_or_create(:user_id => user_id)
  game = Game.create(:current_order => 0)
  bet = Bet.create(:amount => initial_bet)
  bet.user = user
  bet.save
  game.users << user
  game.bets << bet
  game.save
end

def add_user_to_game(user_id, bet)
  user = User.first_or_create(:user_id => user_id)
  game = Game.first(:status => "pregame")
  bet = Bet.create(:amount => bet)
  bet.user = user
  bet.save
  game.users << user
  game.bets << bet
  game.save
end
