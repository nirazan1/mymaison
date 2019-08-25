class Reservation < ActiveRecord::Base
  belongs_to :property
  has_one :user, through: :property
  has_many :guests
end
