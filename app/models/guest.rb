class Guest < ActiveRecord::Base
  validates :name, :surname, :gender, :date_of_birth ,:country_of_birth,
   :nationality, :passport_number, presence: true
  belongs_to :reservation
end
