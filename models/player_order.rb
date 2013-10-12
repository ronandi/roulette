class PlayerOrder
  include DataMapper::Resource

  property :order_num, Serial

  has n, :users
  belongs_to :game
end
