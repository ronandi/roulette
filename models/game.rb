class Game
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :created_at, DateTime
  property :winner, Integer
  property :current_order, Integer
  property :status, String, :default => "pregame"
  property :fatal_order, Integer

  has n, :users
  has n, :bets
  has n, :player_order
end
