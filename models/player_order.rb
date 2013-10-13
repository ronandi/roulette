class PlayerOrder
  include DataMapper::Resource

  property :order_num, Integer

  has 1, :user
  belongs_to :game
end
