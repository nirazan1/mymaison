class Guest < ActiveRecord::Base
  validates :name, :surname, :gender, :date_of_birth ,:country_of_birth,
   :nationality, presence: true
  validates :passport_number, presence: true, if: -> { group_leader? }
  belongs_to :reservation
  scope :leader, -> { where(group_leader: true) }
  scope :pending_sync, -> { where(synced_to_police_portal: false) }

  def full_name
    "#{name} #{surname}"
  end

  GUEST_TYPE = {
    'Single Guest': 16,
    'Householder': 17,
    'Group Leader': 18
  }.with_indifferent_access
end
