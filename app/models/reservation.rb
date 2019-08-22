class Reservation < ActiveRecord::Base
  belongs_to :property
  has_one :user, through: :property
  has_many :guests
  validates :checkin_date, :checkout_date, presence: true
end
