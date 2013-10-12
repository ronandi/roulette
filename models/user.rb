class User
  include DataMapper::Resource

  property :user_id, Integer, :key => true
  property :name, String, :required => true
  property :balance, Decimal, :default => 0
  property :bc_address, String
  property :wins, Integer, :default => 0
end
