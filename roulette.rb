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
      start_new_game(message.sender, message.sender_id, initial_bet)
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
      return add_user_to_game(message.sender, message.sender_id, bet)
    else
      return "Invalid initial bet"
    end
end

Chatbot.command '!pull' do |message|
  return "It is not your turn" unless is_players_turn(message.sender_id)
  game =  Game.first(:status => "in_progress")
  if game.fatal_order == game.current_order
    game_over
  else
    game.update(:current_order => game.current_order + 1)
    return notify_user_of_turn(game.player_orders.first(:order_num => game.current_order).user.name)
  end
end

Chatbot.command '!start' do |message|
  game = Game.first(:status => "pregame")
  unless game.nil?
    game.update(:status => "in_progress")
    random_order = (1..game.users.count).to_a.shuffle
    game.update(:fatal_order => random_order.first)
    game.users.each_with_index do |index, user|
      player_order = PlayerOrder.create(order_num: random_order[index])
      player_order.user = user
      player_order.save
      game.player_orders << player_order
      game.save
    end
    return notify_user_of_turn(game.player_orders.first(:order_num => 1).user.name)
  end
  nil
end

def is_players_turn(user_id)
  game =  Game.first(:status => "in_progress")
  user = User.get(user_id)
  return game.current_order == game.player_orders.first(:user => user).order_num
end

def notify_user_of_turn(name)
  return "#{name} has the gun"
end

def game_in_progress?
  return Game.first(:status.not => "in_progress").nil?
end

def game_in_pregame?
  return Game.first(:status.not => "pregame").nil?
end

def start_new_game(name, user_id, initial_bet)
  user = User.first_or_create(:user_id => user_id)
  user.name = name
  game = Game.create(:current_order => 1)
  bet = Bet.create(:amount => initial_bet)
  bet.user = user
  bet.save
  game.users << user
  game.bets << bet
  game.save
end

def add_user_to_game(name, user_id, bet)
  user = User.first_or_create(:user_id => user_id)
  user.name = name
  game = Game.first(:status => "pregame")
  bet = Bet.create(:amount => bet)
  bet.user = user
  bet.save
  game.users << user
  game.bets << bet
  game.save
end

def game_over
  #TODO
  take_current_users_credits
  distribute_weighted_by_bets_to_all_other_users
  mark_game_as_over
  tell_group_game_over
end
