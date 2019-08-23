class Guest < ActiveRecord::Base
  validates :name, :surname, :gender, :date_of_birth ,:country_of_birth,
   :nationality, :passport_number, presence: true
  belongs_to :reservation
  scope :leader, -> { where(group_leader: true) }

  def full_name
    "#{name} #{surname}"
  end
end
