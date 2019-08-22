class User < ActiveRecord::Base
  has_many :properties
  has_many :reservations, through: :properties, source: :reservations
  has_many :guests, through: :reservations
end
