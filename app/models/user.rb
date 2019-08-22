class User < ActiveRecord::Base
  has_many :properties
  has_many :guests
end
