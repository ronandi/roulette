class Bet
  include DataMapper::Resource

  property :id, Serial
  property :amount, Integer

  has 1, :user
  belongs_to :game
end
