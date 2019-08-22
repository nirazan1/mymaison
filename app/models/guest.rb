class Guest < ActiveRecord::Base
  belongs_to :user
  validates :name, :surname, :gender, :date_of_birth ,:country_of_birth,
   :nationality, :passport_number, presence: true
end
